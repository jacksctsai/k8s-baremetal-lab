# Day 4

Installed Helm v4 on my mac.

Download helm binary from Github at https://github.com/helm/helm/releases/tag/v4.3.1. Verify download files.


```
$ sha256sum -c ~/Downloads/helm-v4.3.1-darwin-arm64.tar.gz.sha256sum
helm-v4.3.1-darwin-arm64.tar.gz: OK
$ gpg --verify helm-v4.3.1-darwin-arm64.tar.gz.asc helm-v4.3.1-darwin-arm64.tar.gz
gpg: Signature made Thu Oct 15 09:01:45 2026 CST
gpg:                using RSA key 208DD36ED5BB3745A16743A4C7C6FBB5B91C1155
gpg: Good signature from "Scott Rigby <scott@r6by.com>" [unknown]
gpg: Signature notation: manu=2,2.5+1.12,0,3
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 208D D36E D5BB 3745 A167  43A4 C7C6 FBB5 B91C 1155
```

The signature is valid and the fingerprint matches the key on the Helm release page, which is good enough for a lab.

Installation

```
$ tar -zxvf ~/Downloads/helm-v4.3.1-darwin-arm64.tar.gz
$ mv ~/Downloads/darwin-arm64/helm /usr/local/bin/helm
```

```
$ helm version
version.BuildInfo{Version:"v4.3.1", GitCommit:"c0d08d0d6d9424d4a14febb5e8a3e51b0dd00dff", GitTreeState:"clean", GoVersion:"go1.27.2", KubeClientVersion:"v1.37"}
```


First, we created the chart `hello-api` at [charts/](charts/) folder.

```
$ helm create hello-api
Creating hello-api
```

Then, we trimmed off the unnecessary syntax and passed the helm lint check.

```
$ helm lint charts/hello-api
==> Linting charts/hello-api
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

However, passing lint check does not give us working templates. We have to compare it with the working configuration.

```
$ helm template hello-api charts/hello-api > /tmp/rendered.yaml
$ diff <(multipass exec cp -- kubectl get deploy,svc,cm -l app.kubernetes.io/name=hello-api -o yaml) /tmp/rendered.yaml
```

An alternative way is to compare the rendered manifests against our previous working manifest files.

After some mapping problems cleared, we came to a point to cutover the old configuration and let helm take over.

But first, we need to manage the kubernetes connection. Currently, the mac connects to the GCP kubernetes cluster. I need to use the kubernetes config from cp to connect to the cluster.

```
$ multipass exec cp -- sudo cat /etc/kubernetes/admin.conf > ~/.kube/lab.conf
$ chmod 600 ~/.kube/lab.conf
$ export KUBECONFIG=~/.kube/lab.conf
```

Then we are ready to do the cutover. The delete is necessary because Helm couldn't adopt the existing resources. The chart's selector adds app.kubernetes.io/instance, and Deployment selectors can't be changed. The old Service hello-api-service also held NodePort 30080.

```
$ kubectl delete -f services/tiny-rest/manifests
configmap "hello-api-config" deleted from default namespace
deployment.apps "hello-api" deleted from default namespace
service "hello-api-service" deleted from default namespace

$ helm install hello-api charts/hello-api
Error: INSTALLATION FAILED: server-side apply failed for object default/hello-api apps/v1, Kind=Deployment: failed to create typed patch object (default/hello-api; apps/v1, Kind=Deployment): errors:
  .spec.template.spec.containers[name="hello-api"].livenessProbe.httpGet.failureThreshold: field not declared in schema
  .spec.template.spec.containers[name="hello-api"].readinessProbe.httpGet.timeoutSeconds: field not declared in schema
```

The probe timing fields were nested under httpGet instead of directly under the probe, and the server rejected them. helm lint doesn't validate against the Kubernetes schema, so helm install --dry-run=server would have caught this before installing.

```
$ helm install hello-api charts/hello-api
level=ERROR msg="release name check failed" error="cannot reuse a name that is still in use"
Error: INSTALLATION FAILED: release name check failed: cannot reuse a name that is still in use
```

The failed install left a release record, so the name was still taken. `helm uninstall` cleared it; `helm upgrade --install` would also work.

```
$ helm uninstall hello-api
release "hello-api" uninstalled

$ helm install hello-api charts/hello-api
NAME: hello-api
LAST DEPLOYED: Thu Oct 15 12:12:51 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NOTES:
Get the application URL:
  export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:30080

$ kubectl get pods,svc -o wide
NAME                             READY   STATUS    RESTARTS   AGE   IP            NODE   NOMINATED NODE   READINESS GATES
pod/hello-api-5f96fb9786-bqwpf   1/1     Running   0          37s   10.244.1.82   w1     <none>           <none>
pod/hello-api-5f96fb9786-r2g4t   1/1     Running   0          37s   10.244.2.41   w2     <none>           <none>
pod/hello-api-5f96fb9786-z4rnm   1/1     Running   0          37s   10.244.2.42   w2     <none>           <none>

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE   SELECTOR
service/hello-api    NodePort    10.109.65.30   <none>        8080:30080/TCP   37s   app.kubernetes.io/instance=hello-api,app.kubernetes.io/name=hello-api
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP          7d    <none>

$ curl http://192.168.252.3:30080/
{"greeting":"Hello from Kubernetes NodePort! Aloha!","version":"v2.0.1","commit":"b338a02","buildAt":"2026-10-12T10:22:06Z","hostname":"hello-api-5f96fb9786-bqwpf"}
```

We managed to get the pods and service up and running. And we are able to get the response from the new pods.

Then assuming we want to change a ConfigMap value, instead of calling `kubectl` we can actually override a value for one release without touching the chart and get helm to upgrade to effect the change. The pods rolled automatically because of the checksum/config annotation. That's the fix for the Day 2 ConfigMap problem.

```
$ helm upgrade hello-api charts/hello-api --set config.GREETING="Hello from Helm"
Release "hello-api" has been upgraded. Happy Helming!
NAME: hello-api
LAST DEPLOYED: Thu Oct 15 12:14:13 2026
NAMESPACE: default
STATUS: deployed
REVISION: 2
DESCRIPTION: Upgrade complete
TEST SUITE: None
NOTES:
Get the application URL:
  export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:30080
$ curl http://192.168.252.3:30080/
{"greeting":"Hello from Helm","version":"v2.0.1","commit":"b338a02","buildAt":"2026-10-12T10:22:06Z","hostname":"hello-api-7c48d6766-jzjwq"}
```

The change is applied successfully and you can see it in the response.

Assume that we now want to revert to the previous version, we can do this by `helm rollback` easily.

```
$ helm rollback hello-api 1
Rollback was a success! Happy Helming!
$ curl http://192.168.252.3:30080/
{"greeting":"Hello from Kubernetes NodePort! Aloha!","version":"v2.0.1","commit":"b338a02","buildAt":"2026-10-12T10:22:06Z","hostname":"hello-api-5f96fb9786-8m6bp"}
```

It is successfully reverted. The new pod after the rollback is 5f96fb9786 again, the same as revision 1. That shows the rollback restored the exact pod template. Now, we can check the history to see what happened from helm's point of view.


```
$ helm history hello-api
REVISION  UPDATED                   STATUS      CHART           APP VERSION DESCRIPTION
1         Thu Oct 15 12:12:51 2026  superseded  hello-api-0.1.0 v2.0.1      Install complete
2         Thu Oct 15 12:14:13 2026  superseded  hello-api-0.1.0 v2.0.1      Upgrade complete
3         Thu Oct 15 12:15:16 2026  deployed    hello-api-0.1.0 v2.0.1      Rollback to 1
```

## Lessons learnt

Lint helps checking the syntax but passing lint does not guarantee it will work live. This is similar to compile time check and runtime check. A dry run is helpful before putting anything on production.

The checksum/config annotation hashes the ConfigMap into the pod template, so any config change forces a rollout. That fixes Day 2's 'ConfigMap changed but pods did not' problem.

Helm only adopts resources carrying its ownership metadata, and even then it can't change immutable fields like a Deployment's selector, so I deleted the old resources and accepted a short outage. Teams should try to start with Helm or Argo CD from day one.
