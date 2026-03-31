# Google Workspace MCP on Railway

## Start command

Use this start command in a dedicated Railway service:

```bash
bash /app/scripts/mcp/google-workspace-http.sh
```

## Required Railway variables

- `GOOGLE_OAUTH_CLIENT_ID`
- `GOOGLE_OAUTH_CLIENT_SECRET`
- `WORKSPACE_EXTERNAL_URL`
- `GOOGLE_OAUTH_REDIRECT_URI=${WORKSPACE_EXTERNAL_URL}/oauth2callback`
- `WORKSPACE_MCP_TOOL_TIER=core`

Optional during first auth:

- `WORKSPACE_MCP_READ_ONLY=true`

## Volume

Mount a persistent volume at `/data`.

## Why a separate service

This keeps the OAuth callback URL and MCP HTTP transport independent from the main OpenClaw wrapper service.

## First consent

After deploy, open the service URL and complete Google OAuth consent. Credentials will persist under:

- `/data/.openclaw/mcp/google-workspace/credentials`
