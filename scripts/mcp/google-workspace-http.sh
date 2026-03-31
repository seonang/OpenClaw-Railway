#!/usr/bin/env bash
set -euo pipefail

VENV_DIR="${WORKSPACE_MCP_VENV:-/data/.openclaw/mcp/google-workspace/venv}"
CREDENTIALS_DIR="${GOOGLE_MCP_CREDENTIALS_DIR:-/data/.openclaw/mcp/google-workspace/credentials}"
TOOL_TIER="${WORKSPACE_MCP_TOOL_TIER:-core}"
PERMISSIONS="${WORKSPACE_MCP_PERMISSIONS:-}"
READ_ONLY="${WORKSPACE_MCP_READ_ONLY:-false}"

read_secret() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "Missing Google Workspace MCP secret file: $path" >&2
    exit 2
  fi
  tr -d '\r\n' < "$path"
}

if [[ -z "${GOOGLE_OAUTH_CLIENT_ID:-}" ]]; then
  GOOGLE_OAUTH_CLIENT_ID="$(read_secret "${GOOGLE_OAUTH_CLIENT_ID_FILE:-/data/workspace/secrets/google-oauth-client-id.txt}")"
fi
if [[ -z "${GOOGLE_OAUTH_CLIENT_SECRET:-}" ]]; then
  GOOGLE_OAUTH_CLIENT_SECRET="$(read_secret "${GOOGLE_OAUTH_CLIENT_SECRET_FILE:-/data/workspace/secrets/google-oauth-client-secret.txt}")"
fi

export GOOGLE_OAUTH_CLIENT_ID
export GOOGLE_OAUTH_CLIENT_SECRET
export GOOGLE_MCP_CREDENTIALS_DIR="$CREDENTIALS_DIR"
mkdir -p "$CREDENTIALS_DIR"

if [[ ! -x "$VENV_DIR/bin/workspace-mcp" ]]; then
  mkdir -p "$(dirname "$VENV_DIR")"
  python3 -m venv "$VENV_DIR"
  "$VENV_DIR/bin/pip" install --upgrade pip >/dev/null
  "$VENV_DIR/bin/pip" install workspace-mcp >/dev/null
fi

args=(--single-user --transport streamable-http --tool-tier "$TOOL_TIER")

if [[ "$READ_ONLY" == "true" ]]; then
  args+=(--read-only)
fi

if [[ -n "$PERMISSIONS" ]]; then
  # shellcheck disable=SC2206
  perms=( $PERMISSIONS )
  args+=(--permissions "${perms[@]}")
fi

exec "$VENV_DIR/bin/workspace-mcp" "${args[@]}"
