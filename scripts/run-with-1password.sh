#!/usr/bin/env bash
# Run a command with env vars from 1Password (op run) and .env (dotenv).
# If .env.op exists, use `op run --env-file=.env.op` to resolve secret references
# and pass the result to the rest of the command. Otherwise run with .env only.
#
# Usage: ./scripts/run-with-1password.sh [command...]
# Example: ./scripts/run-with-1password.sh pnpm dev
# Example: ./scripts/run-with-1password.sh ./scripts/convex-deploy.sh
#
# Requires: 1Password CLI (op) when .env.op is present.
# Setup: cp .env.op.template .env.op and replace with your secret references.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

ENV_OP="$ROOT_DIR/.env.op"
ENV_FILE="$ROOT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env not found. Copy .env.example to .env and configure." >&2
  exit 1
fi

# Build command: dotenv -e .env -- <user command>
RUN_CMD=(dotenv -e "$ENV_FILE" -- "$@")

if [ -f "$ENV_OP" ]; then
  if ! command -v op >/dev/null 2>&1; then
    echo "Error: .env.op found but 1Password CLI (op) is not installed or not in PATH." >&2
    echo "Install from https://developer.1password.com/docs/cli/get-started/ or run without 1Password (remove .env.op)." >&2
    exit 1
  fi
  exec op run --env-file="$ENV_OP" -- "${RUN_CMD[@]}"
else
  exec "${RUN_CMD[@]}"
fi
