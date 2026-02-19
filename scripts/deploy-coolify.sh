#!/usr/bin/env bash
# Deploy Clawe to Coolify 2 (self-hosted). Uses credentials from env (e.g. 1Password via op run).
#
# Usage (with 1Password):
#   op run --env-file=.env.op -- ./scripts/deploy-coolify.sh
#   ./scripts/run-with-1password.sh ./scripts/deploy-coolify.sh
#
# Or set in .env and run:
#   ./scripts/deploy-coolify.sh
#
# Required env: COOLIFY_URL, COOLIFY_API_TOKEN, COOLIFY_RESOURCE_UUID
# Optional: COOLIFY_FORCE=1 to force rebuild without cache
#
# This script targets Coolify 2 only. Not Coolify 1. Not CapRover/capicoolify.

set -e

COOLIFY_URL="${COOLIFY_URL:-}"
COOLIFY_API_TOKEN="${COOLIFY_API_TOKEN:-}"
COOLIFY_RESOURCE_UUID="${COOLIFY_RESOURCE_UUID:-}"
COOLIFY_FORCE="${COOLIFY_FORCE:-0}"

# Reject CapRover / capicoolify
if [[ -n "$COOLIFY_URL" ]] && [[ "$COOLIFY_URL" =~ [Cc]apicoolify|[Cc]aprover ]]; then
  echo "Error: COOLIFY_URL must point to Coolify 2, not CapRover/capicoolify." >&2
  exit 1
fi

if [[ -z "$COOLIFY_URL" ]] || [[ -z "$COOLIFY_API_TOKEN" ]] || [[ -z "$COOLIFY_RESOURCE_UUID" ]]; then
  echo "Error: COOLIFY_URL, COOLIFY_API_TOKEN, and COOLIFY_RESOURCE_UUID are required." >&2
  echo "Set them in .env or .env.op and run with: op run --env-file=.env.op -- ./scripts/deploy-coolify.sh" >&2
  exit 1
fi

# Normalize base URL (no trailing slash); Coolify 2 API is under /api/v1
COOLIFY_BASE="${COOLIFY_URL%/}"
DEPLOY_URL="${COOLIFY_BASE}/deploy"
# If base does not contain /api/v1, use the v1 deploy endpoint
case "$COOLIFY_BASE" in
  *api/v1) ;;
  *) DEPLOY_URL="${COOLIFY_BASE}/api/v1/deploy" ;;
esac

echo "Deploying to Coolify 2 at ${COOLIFY_BASE} (resource UUID: ${COOLIFY_RESOURCE_UUID})..."

# POST with JSON body (API accepts GET with query params or POST with JSON)
FORCE_JSON=""
if [[ "$COOLIFY_FORCE" == "1" ]] || [[ "$COOLIFY_FORCE" == "true" ]]; then
  FORCE_JSON=', "force": true'
fi
BODY="{\"uuid\": \"${COOLIFY_RESOURCE_UUID}\"${FORCE_JSON}}"

HTTP_CODE=$(curl -s -w "%{http_code}" -o /tmp/coolify-deploy-response.json \
  -X POST "$DEPLOY_URL" \
  -H "Authorization: Bearer ${COOLIFY_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$BODY")

if [[ "$HTTP_CODE" -ge 200 ]] && [[ "$HTTP_CODE" -lt 300 ]]; then
  echo "Deploy triggered successfully (HTTP $HTTP_CODE)."
  if command -v jq >/dev/null 2>&1; then
    jq '.' /tmp/coolify-deploy-response.json 2>/dev/null || cat /tmp/coolify-deploy-response.json
  else
    cat /tmp/coolify-deploy-response.json
  fi
  rm -f /tmp/coolify-deploy-response.json
  exit 0
fi

echo "Deploy failed (HTTP $HTTP_CODE). Response:" >&2
cat /tmp/coolify-deploy-response.json 2>/dev/null | head -20
rm -f /tmp/coolify-deploy-response.json
exit 1
