# Day 5


## Install Argo CD

First, we create a namespace `argocd` for Argo CD resources.

```
$ kubectl create namespace argocd
$ kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Install Argo CD CLI tools. Using homebrew to install it will end up in CMake error, we will use curl to download binary instead.

```
$ VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
$ curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-darwin-arm64
$ sudo install -m 555 argocd /usr/local/bin/argocd
$ rm argocd
```

By default, Argo CD isn’t exposed outside the cluster. Setup port forwarding with `kubectl port-forward` so we can connect to the API server without exposing the service.

```
$ kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Now we can access the API server using https://localhost:8080

Before we can login, we still need the auto-generated initial password for the `admin` account. We can retrive that using the `argocd` CLI tool.

```
$ argocd admin initial-password -n argocd
```

This is the first look of the Argo CD API Server.

![Argo CD API Server First Look](images/day5-ArgoCD-API-server-first-look.png)


### Pointing Argo CD at the chart with an Argo CD Application

The application manifest is created at [argocd/hello-api.yaml](../argocd/hello-api.yaml). We apply it with `kubectl apply` and leave it auto-sync off for now.

```
$ kubectl apply -n argocd -f argocd/hello-api.yaml
application.argoproj.io/hello-api created
```

Go to the Argo CD API server UI, we can see the application is created but out of sync.

![Argo CD Application Created OutOfSync](images/day5-ArgoCD-application-created.png)

To work on the out-of-sync problem, we can look at the diff on the UI. But I prefer to use CLI tool to get searchable text with `argocd app diff`.

```
$ argocd app diff hello-api
{"level":"fatal","msg":"Argo CD server address unspecified","time":"2026-10-16T11:06:47+08:00"}
```

We haven't logged in to the API server yet on the CLI tool. We can do so with `argocd login`. The TLS warning is telling us the certificate is not verifiable because it is a self-signed certificate by default, which is fine in our lab case.

```
$ argocd login 127.0.0.1:8080
WARNING: server certificate had error: error creating connection: tls: failed to verify certificate: x509: certificate signed by unknown authority. Proceed insecurely (y/n)? y
Username: admin
Password:
'admin:login' logged in successfully
Context '127.0.0.1:8080' updated

$ argocd app diff hello-api

===== apps/Deployment default/hello-api ======
172a173,175
>         - containerPort: 0
>           name: http
>           protocol: TCP
```

`service.targetPort` was missing from the committed `values.yaml`, so Argo CD, which renders the chart from git, got an empty value and rendered `containerPort: 0`. The live Deployment still had 8080 from an earlier install, so the gap went unnoticed until Argo CD compared git against the cluster.

We added it back and confirmed with `helm template` and then pushed the changes.

```
$ helm template charts/hello-api | grep -B2 -A2 containerPort
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          livenessProbe:

$ git add charts/hello-api/values.yaml
$ git commit -m 'Add missing service.targetPort to hello-api values'
$ git push
```

Now we go to the API server and refresh, we can see the application status became `Synced` without a manual sync after the push.

![Argo CD Application Synced](images/day5-ArgoCD-application-synced.png)

