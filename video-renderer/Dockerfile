FROM node:20-bookworm-slim

# Install Chromium and its system dependencies for headless rendering.
# bookworm-slim ships a minimal glibc environment; Chromium pulls in what it needs.
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    fonts-liberation \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /sbin/nologin appuser

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY src ./src

RUN chown -R appuser:appuser /app
USER appuser

ENV PORT=3100
ENV RENDER_OUTPUT_DIR=/tmp/render_artifacts
# Point Remotion at the system Chromium installed above.
ENV REMOTION_CHROME_EXECUTABLE=/usr/bin/chromium

EXPOSE 3100

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3100/health || exit 1

CMD ["node", "src/server.js"]
