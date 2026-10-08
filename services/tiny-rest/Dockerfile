# Explicitly pin linux/arm64 architecture and a minimal slim Node base
FROM --platform=linux/arm64 node:20-slim

# Set production environment
ENV NODE_ENV=production

WORKDIR /app

# Copy dependency definitions first to leverage layer caching
COPY package*.json ./

# Install only production dependencies cleanly
RUN npm ci --omit=dev && npm cache clean --force

# Copy application source
COPY server.js ./

# Use the built-in non-root 'node' user (UID 1000) for security
USER node

# Expose target port
EXPOSE 8080

# Run using node directly (avoids npm signal trapping issues with SIGTERM)
CMD ["node", "server.js"]