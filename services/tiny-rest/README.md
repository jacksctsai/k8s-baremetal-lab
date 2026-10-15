# hello-api

Minimal Node.js Express service for Kubernetes testing. Exposes `/`, `/healthz`, and `/readyz`.

## Local Run

```bash
npm install && npm start
```

## Build & Push (arm64)

```bash
docker build --platform linux/arm64 \
  --build-arg APP_VERSION="$(git describe --tags --always)" \
  --build-arg GIT_COMMIT="$(git rev-parse --short HEAD)" \
  --build-arg BUILD_TIME="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  -t ghcr.io/jacksctsai/hello-api:$(git describe --tags --always) .
docker push ghcr.io/jacksctsai/hello-api:$(git describe --tags --always)
```

## Deploy

```bash
helm install hello-api ../../charts/hello-api
```

Access via any node IP on port `30080`.