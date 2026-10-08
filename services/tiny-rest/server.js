import express from 'express';
import os from 'os';

const app = express();
const PORT = process.env.PORT || 8080;
const APP_VERSION = process.env.APP_VERSION || '1.0.0';
const GREETING = process.env.GREETING || 'Hello, World!';

// Liveness probe
app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Readiness probe
app.get('/readyz', (req, res) => {
  // Add dependency checks here (e.g., DB connected, cache warm)
  res.status(200).json({ status: 'ready' });
});

// Root endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    greeting: GREETING,
    version: APP_VERSION,
    hostname: os.hostname() // Returns the Pod name in Kubernetes
  });
});

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});

process.on('SIGTERM', () => {
  console.log('Received SIGTERM, closing HTTP server...');
  server.close(() => {
    console.log('HTTP server closed, exiting process.');
    process.exit(0);
  });
});
