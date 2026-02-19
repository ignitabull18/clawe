#!/usr/bin/env bash
# Set up Google OAuth 2.0 credentials for NextAuth "Sign in with Google".
# Uses gcloud to configure the project and open the Cloud Console; the actual
# OAuth client (Web application) must be created in the Console.
#
# Usage: ./scripts/setup-google-oauth.sh [GCP_PROJECT_ID]
# If GCP_PROJECT_ID is omitted, uses current gcloud project.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
REDIRECT_URI="http://localhost:3000/api/auth/callback/google"

# Project
if [ -n "$1" ]; then
  PROJECT_ID="$1"
  echo "==> Using project: $PROJECT_ID"
  gcloud config set project "$PROJECT_ID"
else
  PROJECT_ID=$(gcloud config get-value project 2>/dev/null || true)
  if [ -z "$PROJECT_ID" ]; then
    echo "Error: No project set. Run: gcloud config set project YOUR_PROJECT_ID" >&2
    echo "Or pass project as first argument: $0 YOUR_PROJECT_ID" >&2
    exit 1
  fi
  echo "==> Using current project: $PROJECT_ID"
fi

# Ensure user is logged in
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | head -1 | grep -q .; then
  echo "==> Logging in to Google Cloud..."
  gcloud auth login
fi

# Enable APIs required for OAuth consent (user profile, email)
echo "==> Enabling APIs (for OAuth consent screen)..."
gcloud services enable people.googleapis.com --project="$PROJECT_ID" 2>/dev/null || true

# Open Cloud Console to OAuth consent screen (must be configured before creating client)
CONSENT_URL="https://console.cloud.google.com/apis/credentials/consent?project=${PROJECT_ID}"
echo "==> Opening OAuth consent screen (configure if needed)..."
echo "    $CONSENT_URL"
open "$CONSENT_URL" 2>/dev/null || xdg-open "$CONSENT_URL" 2>/dev/null || echo "    Open the URL above in your browser."

# Open Credentials page to create OAuth 2.0 Client ID
CREDENTIALS_URL="https://console.cloud.google.com/apis/credentials?project=${PROJECT_ID}"
echo ""
echo "==> Opening Credentials page..."
echo "    $CREDENTIALS_URL"
open "$CREDENTIALS_URL" 2>/dev/null || xdg-open "$CREDENTIALS_URL" 2>/dev/null || true

echo ""
echo "==> In the Cloud Console:"
echo "    1. If prompted, configure the OAuth consent screen (External, add your email as test user)."
echo "    2. Click '+ CREATE CREDENTIALS' → 'OAuth client ID'."
echo "    3. Application type: 'Web application'."
echo "    4. Name: e.g. 'Clawe Local'."
echo "    5. Authorized redirect URIs: add exactly:"
echo "       $REDIRECT_URI"
echo "    6. Create, then copy the Client ID and Client secret."
echo ""
echo "==> Add to your .env (or .env.op with 1Password secret references):"
echo "    GOOGLE_CLIENT_ID=<your-client-id>.apps.googleusercontent.com"
echo "    GOOGLE_CLIENT_SECRET=<your-client-secret>"
echo ""
echo "==> Optional: save credentials into .env now (will append, not overwrite)."
if [ -t 0 ]; then
  read -r -p "    Enter Client ID (or press Enter to skip): " CLIENT_ID
  if [ -n "$CLIENT_ID" ]; then
    read -r -p "    Enter Client secret: " CLIENT_SECRET
    if [ -n "$CLIENT_SECRET" ]; then
      ENV_FILE="$ROOT_DIR/.env"
      if [ ! -f "$ENV_FILE" ]; then
        cp "$ROOT_DIR/.env.example" "$ENV_FILE"
      fi
      # Remove any existing GOOGLE_ lines then append
      if grep -q "^GOOGLE_CLIENT_ID=" "$ENV_FILE" 2>/dev/null; then
        if sed --version 2>/dev/null | grep -q GNU; then
          sed -i '/^GOOGLE_CLIENT_ID=/d;/^GOOGLE_CLIENT_SECRET=/d' "$ENV_FILE"
        else
          sed -i '' '/^GOOGLE_CLIENT_ID=/d;/^GOOGLE_CLIENT_SECRET=/d' "$ENV_FILE"
        fi
      fi
      echo "" >> "$ENV_FILE"
      echo "# Google OAuth (from setup-google-oauth.sh)" >> "$ENV_FILE"
      echo "GOOGLE_CLIENT_ID=$CLIENT_ID" >> "$ENV_FILE"
      echo "GOOGLE_CLIENT_SECRET=$CLIENT_SECRET" >> "$ENV_FILE"
      echo "    Wrote GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET to .env"
    fi
  fi
fi
echo "    Done."
