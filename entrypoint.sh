#!/bin/sh
set -e
: "${UUID:?UUID is required}"
: "${WS_PATH:?WS_PATH is required}"
PORT="${PORT:-8080}"
cat > /etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [{
    "listen": "0.0.0.0",
    "port": ${PORT},
    "protocol": "vless",
    "settings": {
      "clients": [{ "id": "${UUID}" }],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": { "path": "${WS_PATH}" }
    }
  }],
  "outbounds": [{ "protocol": "freedom", "tag": "direct" }]
}
EOF
exec /usr/bin/xray -config /etc/xray/config.json
