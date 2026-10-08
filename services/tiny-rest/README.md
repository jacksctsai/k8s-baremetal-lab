# hello-api

Minimal Node.js Express service for Kubernetes testing. Exposes `/`, `/healthz`, and `/readyz`.

## Local Run

```bash
npm install && npm start
```

## Build & Push (arm64)

```bash
docker build --platform linux/arm64 -t ghcr.io/jacksctsai/hello-api:v1 .
docker push ghcr.io/jacksctsai/hello-api:v1
```

## Deploy

```bash
kubectl apply -f manifests/
```

Access via any node IP on port `30080`.