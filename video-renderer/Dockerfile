FROM node:20-bookworm-slim

# Install Chromium and its system dependencies for headless rendering.
# bookworm-slim ships a minimal glibc environment; Chromium pulls in what it needs.
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY src ./src

ENV PORT=3100
ENV RENDER_OUTPUT_DIR=/render_artifacts
# Point Remotion at the system Chromium installed above.
ENV REMOTION_CHROME_EXECUTABLE=/usr/bin/chromium

EXPOSE 3100

CMD ["node", "src/server.js"]
