# Day 2


The hardcoded APP_VERSION removed from the deployment manfest's `env`.

Timed `kubectl delete pod` in the following result:

```
pod "hello-api-5bb5d6d67-7rj4x" deleted from default namespace

real  0m31.578s
user  0m0.088s
sys 0m0.061s
```


Then do `kubectl apply -f manifests/` with updated deployment.manifest. The new app version `1.0.1` is deployed across the pods in a few seconds.

And this is the curl log.

```
$ while true; do date; curl -s http://192.168.252.2:30080; echo; sleep 0.3; done
Mon Oct 12 15:45:55 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:45:55 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:45:55 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.0","hostname":"hello-api-6cf8d7856f-f66kz"}
Mon Oct 12 15:45:56 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:45:56 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-rzckr"}
Mon Oct 12 15:45:56 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:45:57 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.0","hostname":"hello-api-6cf8d7856f-f66kz"}
Mon Oct 12 15:45:57 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-rzckr"}
Mon Oct 12 15:45:57 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.0","hostname":"hello-api-6cf8d7856f-f66kz"}
Mon Oct 12 15:45:58 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:45:58 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:45:58 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-rzckr"}
Mon Oct 12 15:45:59 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-rzckr"}
Mon Oct 12 15:45:59 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:45:59 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:46:00 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:46:00 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-rzckr"}
Mon Oct 12 15:46:01 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:46:01 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.0","hostname":"hello-api-6cf8d7856f-f66kz"}
Mon Oct 12 15:46:01 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:46:02 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-rzckr"}
Mon Oct 12 15:46:02 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-ldm9n"}
Mon Oct 12 15:46:02 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:46:03 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:46:03 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-rzckr"}
Mon Oct 12 15:46:03 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-ldm9n"}
Mon Oct 12 15:46:04 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:46:04 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-ldm9n"}
Mon Oct 12 15:46:04 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-ldm9n"}
Mon Oct 12 15:46:05 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-ldm9n"}
Mon Oct 12 15:46:05 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-ldm9n"}
Mon Oct 12 15:46:05 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-ldm9n"}
Mon Oct 12 15:46:06 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-rzckr"}
Mon Oct 12 15:46:06 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-49p89"}
Mon Oct 12 15:46:06 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-rzckr"}
Mon Oct 12 15:46:07 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-ldm9n"}
Mon Oct 12 15:46:07 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-rzckr"}
Mon Oct 12 15:46:07 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-rzckr"}
Mon Oct 12 15:46:08 CST 2026
{"greeting":"Hello from Kubernetes NodePort!","version":"v1.0.1","hostname":"hello-api-5d7f5667fd-rzckr"}
Mon Oct 12 15:46:08 CST 2026
```


Then, we added some more changes for the preparation for CI/CD integration later. Specifically, there are two fields `commit` and `buildAt` in the `/` response and tagged it `v2.0.0`.

This time, instead of `kubectl apply` we do `kubectl set image deploy/hello-api hello-api=ghcr.io/jacksctsai/hello-api:v2.0.0` and then `kubectl rollout status deploy/hello-api`. Before we do the two commands, we run `while true; do curl -s http://192.168.252.2:30080; echo; sleep 0.3; done` from w1 VM. And observe the response changes.

```
$ kubectl set image deploy/hello-api hello-api=ghcr.io/jacksctsai/hello-api:v2.0.0
deployment.apps/hello-api image updated
```

```
$ kubectl rollout history deploy/hello-api
deployment.apps/hello-api
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>
4         <none>
```

The `kubectl rollout undo` command brought the version back to v1.0.1.

```
$ kubectl rollout undo deploy/hello-api
deployment.apps/hello-api rolled back
```

Then, we changed `manifests/configmap.yaml` with the following where a change in the GREETING value is introduced.

```manifest/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: hello-api-config
  labels:
    app.kubernetes.io/name: hello-api
data:
  GREETING: "Hello from Kubernetes NodePort! Aloha!"
```


Then we do `kubectl apply -f manifests/` on VM cp. But the service response didn't change because env vars are read only when a container starts, so updating the ConfigMap doesn't affect running pods.

We tried `kubectl set image deploy/hello-api hello-api=ghcr.io/jacksctsai/hello-api:v2.0.0` and it worked. The output is now with the updated GREETING, "Hello from Kubernetes NodePort! Aloha!", because the command created new pods, and it also changed the version. The command `kubectl rollout restart deploy/hello-api` would restart the pods and re-read the env vars, too.

In order to measure the time for `kill pod`, we did it again and get the following result. This is much more normal time that we expect. v1.0.0 had no SIGTERM handler, so the kubelet waited the full 30-second grace period. The handler added in v1.0.1 makes the app exit immediately.

```
$ time kubectl delete pod hello-api-6b8f9cb586-gwq4s
pod "hello-api-6b8f9cb586-gwq4s" deleted from default namespace

real  0m1.203s
user  0m0.120s
sys 0m0.093s
```

Another issue we noticed is the curl log the requests failed with 000 sometimes that I have to restart the curl log. It happened right when an old pod was shutting down. The likely cause: the pod stopped accepting connections before kube-proxy had removed it from the Service's endpoints. We added the `preStop` hook to the `deployment.manifest` so the kubelet would wait 5 seconds before sending SIGTERM to the Node.js app. The 5-second sleep keeps the app serving until every node has caught up, and only then does SIGTERM arrive.

```deployment.manifest
(...)
        - name: hello-api
        (...)
          lifecycle:
            preStop:
              exec:
                command: ["sleep", "5"]
(...)
```

We collect the response code to verify the fix using this command, `while true; do   curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 1 http://192.168.252.2:30080;   sleep 0.1; done | tee /tmp/rollout_status.log`.

Before the `preStop`, we measured the result:
```
$ sort /tmp/rollout_status.log | uniq -c
      3 000
    316 200
```

After the `preStop`, the 000 response code is gone:
```
$ sort /tmp/rollout_status.log | uniq -c
    302 200
```
