# Tiny REST API

A lightweight, production-ready Node.js REST API built with Express. Designed primarily for containerized environments and Kubernetes deployments, it includes standard liveness and readiness probe endpoints along with runtime pod metadata inspection.

---

## Features

- **Probes Included:** `/healthz` (liveness) and `/readyz` (readiness).
- **Runtime Metadata:** `/` returns dynamic runtime info including version and host/pod name.
- **Configurable:** Driven entirely by environment variables with sensible defaults.
- **ES Modules:** Built using standard modern JavaScript (`"type": "module"`).
- **Fast Local Dev:** Uses Node's native file-watching (`--watch`) without external overhead.

---

## Endpoints

| Method | Path       | Description                                               | Sample Response |
| :----- | :--------- | :-------------------------------------------------------- | :-------------- |
| `GET`  | `/`        | Returns greeting, configured app version, and hostname/pod name. | `{"greeting":"Hello, World!","version":"1.0.0","hostname":"node-pod-abc"}` |
| `GET`  | `/healthz` | Liveness probe indicating server process is alive.         | `{"status":"ok"}` |
| `GET`  | `/readyz`  | Readiness probe indicating server is ready for traffic.   | `{"status":"ready"}` |

---

## Environment Variables

| Variable      | Type     | Default         | Description                                                        |
| :------------ | :------- | :-------------- | :----------------------------------------------------------------- |
| `PORT`        | `number` | `8080`          | HTTP port the server binds to.                                     |
| `APP_VERSION` | `string` | `1.0.0`         | Semantic version string returned in root endpoint payload.        |
| `GREETING`    | `string` | `Hello, World!` | Greeting message displayed on the root endpoint.                   |

---

## Getting Started

### Prerequisites

- **Node.js:** `v18.11.0` or higher (required for native `--watch` flag)
- **npm:** `v9.0.0` or higher

### Installation

Clone the repository and install dependencies:

```bash
git clone <repository-url>
cd tiny-k8s-api
npm install
```

### Development

Run the server with automatic restart on file change:

```bash
npm run dev
```

### Production

Start the service standardly:

```bash
npm start
```

### Passing Custom Environment Variables

> **Tip:** Use single quotes (`'`) around values containing exclamation marks (`!`) to avoid bash history expansion issues.

```bash
PORT=3000 GREETING='Welcome to the cluster!' APP_VERSION='2.0.0' npm start
```

---

## Testing Endpoints

Once the application is running, test with `curl`:

```bash
# Check root endpoint
curl http://localhost:8080/

# Check liveness
curl http://localhost:8080/healthz

# Check readiness
curl http://localhost:8080/readyz
```

---

## Kubernetes Probe Example

If deploying to Kubernetes, attach the probes to your pod spec:

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /readyz
    port: 8080
  initialDelaySeconds: 2
  periodSeconds: 5
```

---

## License

MIT