# MCP config (from 1Password "Local MCP Config")

Credentials are resolved at runtime via 1Password CLI (`op run --env-file=.cursor/.env.op.mcp`). Ensure you're signed in: `op signin`.

## Servers added from secure note

- **composio** – `~/.cursor/mcp-servers/composio-mcp-server` (Python/uv)
- **coolify** – `~/.cursor/mcp-servers/coolify-mcp-server/build/index.js`
- **hostinger** – `~/.cursor/mcp-servers/hostinger-mcp-server/index.js`
- **devin** – `~/.cursor/mcp-servers/mcpdevin/build/index.js`
- **resend** – `~/.cursor/mcp-servers/resend-mcp-server/mcpServer.js`
- **twenty-crm** – `~/.cursor/mcp-servers/twenty-crm-mcp-server/index.js`

If a server fails to start, install or clone it into the path above (or update paths in `.cursor/mcp.json`).

**Postman** and **notebooklm** are already in your global Cursor MCP config.
