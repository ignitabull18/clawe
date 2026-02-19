FROM node:22-slim AS builder
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate
WORKDIR /app

# Copy package manifests for dependency installation
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/cli/package.json ./packages/cli/
COPY packages/squadhub-extensions/package.json ./packages/squadhub-extensions/
COPY packages/shared/package.json ./packages/shared/
COPY packages/backend/package.json ./packages/backend/
COPY packages/typescript-config/package.json ./packages/typescript-config/
ENV NODE_ENV=development
RUN pnpm install --frozen-lockfile

# Copy source and build CLI + extensions
COPY packages/cli/ ./packages/cli/
COPY packages/squadhub-extensions/ ./packages/squadhub-extensions/
COPY packages/shared/ ./packages/shared/
COPY packages/backend/ ./packages/backend/
COPY packages/typescript-config/ ./packages/typescript-config/
RUN pnpm --filter @clawe/cli run build && pnpm --filter @clawe/squadhub-extensions run build

# Runtime
FROM node:22-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    git \
    cmake \
    make \
    g++ \
    gettext-base \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g openclaw@2026.2.17

RUN mkdir -p /data/config /data/workspace

# Copy templates and scripts
COPY docker/squadhub/templates/ /opt/clawe/templates/
COPY docker/squadhub/scripts/ /opt/clawe/scripts/
RUN chmod +x /opt/clawe/scripts/*.sh

# Copy built CLI (single bundled file)
COPY --from=builder /app/packages/cli/dist/clawe.js /usr/local/bin/clawe
RUN chmod +x /usr/local/bin/clawe

# Copy built OpenClaw extensions (plugin bundle + manifest)
COPY --from=builder /app/packages/squadhub-extensions/dist/index.js /opt/clawe/extensions/clawe/dist/index.js
COPY packages/squadhub-extensions/openclaw.plugin.json /opt/clawe/extensions/clawe/openclaw.plugin.json
COPY packages/squadhub-extensions/package.json /opt/clawe/extensions/clawe/package.json

ENV OPENCLAW_STATE_DIR=/data/config
ENV OPENCLAW_PORT=18789
ENV OPENCLAW_SKIP_GMAIL_WATCHER=1

COPY docker/squadhub/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=5s --timeout=3s --retries=10 \
    CMD wget -q --spider http://localhost:${OPENCLAW_PORT}/health || exit 1

EXPOSE ${OPENCLAW_PORT}

ENTRYPOINT ["/entrypoint.sh"]
