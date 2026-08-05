FROM node:20-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci

COPY . .

FROM node:20-alpine

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app ./

RUN npm prune --omit=dev \
 && npm cache clean --force \
 && addgroup -S nodeapp \
 && adduser -S nodeapp -G nodeapp \
 && chown -R nodeapp:nodeapp /usr/src/app

USER nodeapp

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/health || exit 1

CMD ["node", "src/server.js"]
