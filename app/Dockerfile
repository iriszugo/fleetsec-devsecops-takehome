FROM node:20-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci

COPY . .

RUN npm prune --omit=dev

FROM node:20-alpine AS runtime

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app ./

# npm is not required at runtime.
# Remove npm and its bundled dependencies to reduce attack surface.
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx && addgroup -S nodeapp && adduser -S nodeapp -G nodeapp && chown -R nodeapp:nodeapp /usr/src/app

USER nodeapp

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD node -e "require('http').get({host:'127.0.0.1',port:3000,path:'/health'},r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

CMD ["node", "src/server.js"]
