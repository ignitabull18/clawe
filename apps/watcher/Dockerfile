FROM node:22-alpine AS base
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate
WORKDIR /app

# Install dependencies
FROM base AS deps
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/watcher/package.json ./apps/watcher/
COPY packages/shared/package.json ./packages/shared/
COPY packages/backend/package.json ./packages/backend/
COPY packages/typescript-config/package.json ./packages/typescript-config/
RUN pnpm install --frozen-lockfile

# Build
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/apps/watcher/node_modules ./apps/watcher/node_modules
COPY --from=deps /app/packages/shared/node_modules ./packages/shared/node_modules
COPY --from=deps /app/packages/backend/node_modules ./packages/backend/node_modules
COPY . .
RUN pnpm --filter @clawe/shared run build && pnpm --filter @clawe/watcher run build

# Runner
FROM node:22-slim
WORKDIR /app

COPY --from=builder /app/apps/watcher/dist/ ./dist/
COPY --from=builder /app/packages/shared/dist/ ./node_modules/@clawe/shared/dist/
COPY --from=builder /app/packages/shared/package.json ./node_modules/@clawe/shared/package.json
COPY --from=builder /app/packages/backend/convex/_generated/ ./node_modules/@clawe/backend/convex/_generated/
COPY --from=builder /app/packages/backend/convex/*.ts ./node_modules/@clawe/backend/convex/
COPY --from=builder /app/packages/backend/package.json ./node_modules/@clawe/backend/package.json

RUN echo '{"name":"@clawe/watcher","private":true,"type":"module"}' > package.json
RUN npm install convex axios ws moment-timezone --omit=dev

ENV NODE_ENV=production

CMD ["node", "dist/index.js"]
