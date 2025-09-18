# 1. **Builder stage**
#    - uses `node:20`
#    - installs *all* deps (including dev)  
#    - builds TypeScript (`npm run build`)
#    - removes dev deps: `npm prune --omit=dev`
# 2. **Runtime stage**
#    - uses `node:20-alpine`
#    - copies only required files
#    - **runs as non-root** user
#    - add a `HEALTHCHECK` hitting `http://127.0.0.1:3000/health`
# 4. **No secrets** baked into image
# 5. **No npm** *required* at runtime (direct `node` entrypoint)
FROM  node:20  AS builder
WORKDIR /app
COPY package.json .
RUN npm install 
COPY . .
RUN npm run build
RUN npm prune --omit=dev
###################################
FROM node:20-alpine AS runtime
WORKDIR /app
RUN addgroup -g 1001 -S nodejs
RUN adduser -S node_user -u 1001 -G nodejs
COPY --from=builder /app/package.json .
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
USER node_user
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/health || exit 1
CMD ["node", "dist/index.js"]