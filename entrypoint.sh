#!/bin/sh
# entrypoint.sh — PaaS entrypoint for sing-box.
# Config is NOT baked into the image: it is rendered at runtime from the
# template + environment variables, so the GitHub repo contains no secrets
# and one repo serves every node. Each platform app sets its own env vars:
#   WS mode (default): UUID, WS_PATH, PORT (optional, default 8080)
#   REALITY mode (CONFIG_TEMPLATE=config-reality.json): UUID, PRIVATE_KEY,
#   SHORT_ID, SERVER_NAME (optional, default www.microsoft.com), PORT
# If UUID is missing the container fails fast with a clear error.
set -eu
PORT="${PORT:-8080}"
TEMPLATE="${CONFIG_TEMPLATE:-config-template.json}"
UUID="${UUID:-}"
if [ -z "$UUID" ]; then echo "UUID env var is required" >&2; exit 1; fi
if [ "$TEMPLATE" = "config-reality.json" ]; then
  PRIVATE_KEY="${PRIVATE_KEY:-}"
  SHORT_ID="${SHORT_ID:-}"
  if [ -z "$PRIVATE_KEY" ] || [ -z "$SHORT_ID" ]; then
    echo "PRIVATE_KEY and SHORT_ID env vars are required for REALITY mode" >&2; exit 1
  fi
else
  WS_PATH="${WS_PATH:-}"
  if [ -z "$WS_PATH" ]; then echo "WS_PATH env var is required" >&2; exit 1; fi
fi
sed -e "s|{{UUID}}|${UUID}|g" \
    -e "s|{{WS_PATH}}|${WS_PATH:-}|g" \
    -e "s|{{PORT}}|${PORT}|g" \
    -e "s|{{SERVER_NAME}}|${SERVER_NAME:-www.microsoft.com}|g" \
    -e "s|{{PRIVATE_KEY}}|${PRIVATE_KEY:-}|g" \
    -e "s|{{SHORT_ID}}|${SHORT_ID:-}|g" \
    "/app/${TEMPLATE}" > /tmp/config.runtime.json
exec /usr/local/bin/sing-box run -c /tmp/config.runtime.json
