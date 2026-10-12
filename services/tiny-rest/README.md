# hello-api

Minimal Node.js Express service for Kubernetes testing. Exposes `/`, `/healthz`, and `/readyz`.

## Local Run

```bash
npm install && npm start
```

## Build & Push (arm64)

```bash
VERSION="v2.0.0"
docker build --platform linux/arm64 --build-arg APP_VERSION="${VERSION}" -t ghcr.io/jacksctsai/hello-api:${VERSION} .
docker push ghcr.io/jacksctsai/hello-api:${VERSION}
```

## Deploy

```bash
kubectl apply -f manifests/
```

Access via any node IP on port `30080`.