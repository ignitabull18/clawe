import type { AuthConfig } from "convex/server";

// Fallbacks for local dev so `convex dev` can start without deployment env vars.
// sync-convex-env.sh sets NEXTAUTH_ISSUER_URL and NEXTAUTH_JWKS_URL once the backend is up.
const issuer =
  process.env.NEXTAUTH_ISSUER_URL ?? "http://localhost:3000";
const jwks =
  process.env.NEXTAUTH_JWKS_URL ??
  (() => {
    try {
      const fs = require("node:fs");
      const path = require("node:path");
      const jwksPath = path.join(__dirname, "dev-jwks", "jwks.json");
      const raw = fs.readFileSync(jwksPath, "utf8");
      return `data:application/json,${encodeURIComponent(raw.trim())}`;
    } catch {
      return "data:application/json,{}";
    }
  })();

export default {
  providers: [
    {
      type: "customJwt",
      issuer,
      jwks,
      applicationID: "convex",
      algorithm: "RS256",
    },
  ],
} satisfies AuthConfig;
