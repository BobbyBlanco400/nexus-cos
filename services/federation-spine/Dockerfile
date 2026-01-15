FROM node:20-alpine
ARG N3XUS_HANDSHAKE
ENV N3XUS_HANDSHAKE=${N3XUS_HANDSHAKE}
WORKDIR /app
RUN if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then echo "❌ N3XUS HANDSHAKE VIOLATION" && exit 1; fi
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
CMD ["node", "index.js"]
