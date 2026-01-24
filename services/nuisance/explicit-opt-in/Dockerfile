FROM node:20-alpine

ARG N3XUS_HANDSHAKE
ENV N3XUS_HANDSHAKE=${N3XUS_HANDSHAKE}

WORKDIR /app

# N3XUS Handshake enforcement at BUILD time
RUN if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then \
      echo "❌ N3XUS HANDSHAKE VIOLATION" && exit 1; \
    fi

COPY package*.json ./
RUN npm install --only=production

COPY . .

EXPOSE 4005

CMD ["node", "server.js"]
