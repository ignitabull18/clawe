#!/bin/bash
set -e

# Deploy Convex backend with the correct auth config.
#
# Works with Convex Cloud or self-hosted Convex. For self-hosted, set
# CONVEX_SELF_HOSTED_URL and CONVEX_SELF_HOSTED_ADMIN_KEY in .env.
#
# Copies the right auth.config template based on AUTH_PROVIDER:
#   AUTH_PROVIDER=cognito  → auth.config.cognito.ts (requires Cognito env vars)
#   AUTH_PROVIDER=nextauth → auth.config.nextauth.ts (default, local / self-hosted)
#
# Usage:
#   AUTH_PROVIDER=cognito ./scripts/convex-deploy.sh
#   AUTH_PROVIDER=nextauth ./scripts/convex-deploy.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONVEX_DIR="$ROOT_DIR/packages/backend/convex"

AUTH_PROVIDER="${AUTH_PROVIDER:-nextauth}"

echo "==> Deploying Convex (AUTH_PROVIDER=$AUTH_PROVIDER)"

if [ "$AUTH_PROVIDER" = "cognito" ]; then
    echo "==> Using Cognito auth config"
    cp "$CONVEX_DIR/auth.config.cognito.ts" "$CONVEX_DIR/auth.config.ts"

    # Set Cognito env vars in Convex
    pnpm --filter @clawe/backend exec convex env set COGNITO_ISSUER_URL "$COGNITO_ISSUER_URL"
    pnpm --filter @clawe/backend exec convex env set COGNITO_CLIENT_ID "$COGNITO_CLIENT_ID"
else
    echo "==> Using NextAuth config (local / self-hosted)"
    cp "$CONVEX_DIR/auth.config.nextauth.ts" "$CONVEX_DIR/auth.config.ts"

    # Set NextAuth env vars in Convex (build JWKS data URI from dev-jwks if not set)
    [ -n "$NEXTAUTH_URL" ] && pnpm --filter @clawe/backend exec convex env set NEXTAUTH_ISSUER_URL "$NEXTAUTH_URL"
    if [ -n "$NEXTAUTH_JWKS_URL" ]; then
        pnpm --filter @clawe/backend exec convex env set NEXTAUTH_JWKS_URL "$NEXTAUTH_JWKS_URL"
    elif [ -f "$CONVEX_DIR/dev-jwks/jwks.json" ]; then
        NEXTAUTH_JWKS_URL=$(python3 -c "import urllib.parse, sys; print('data:application/json,' + urllib.parse.quote(sys.stdin.read().strip()))" < "$CONVEX_DIR/dev-jwks/jwks.json")
        pnpm --filter @clawe/backend exec convex env set NEXTAUTH_JWKS_URL "$NEXTAUTH_JWKS_URL"
    fi
fi

# Set watcher token in Convex
if [ -n "$WATCHER_TOKEN" ]; then
    pnpm --filter @clawe/backend exec convex env set WATCHER_TOKEN "$WATCHER_TOKEN"
fi

# Deploy Convex functions and schema
pnpm --filter @clawe/backend deploy

echo "==> Convex deployment complete"
