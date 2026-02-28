FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY src ./src

ENV PORT=3100
ENV RENDER_OUTPUT_DIR=/render_artifacts

EXPOSE 3100

CMD ["npm", "run", "dev"]
