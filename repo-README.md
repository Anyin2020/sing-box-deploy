# sing-box-deploy

Minimal sing-box Docker image for PaaS deployment. The config is rendered at
container startup from a template plus environment variables, so this repo
contains no credentials and one image serves any number of nodes.

## Environment variables

| Variable | Required | Description |
|---|---|---|
| `UUID` | yes | VLESS user UUID (generate a fresh one per node) |
| `WS_PATH` | yes (WS mode) | WebSocket path, e.g. `/a1b2c3d4` |
| `PORT` | no (default `8080`) | Listening port, injected by the platform |
| `CONFIG_TEMPLATE` | no (default `config-template.json`) | `config-template.json` (VLESS+WS) or `config-reality.json` (VLESS+REALITY) |
| `PRIVATE_KEY` | yes (REALITY mode) | X25519 private key for REALITY |
| `SHORT_ID` | yes (REALITY mode) | REALITY short ID |
| `SERVER_NAME` | no (default `www.microsoft.com`) | REALITY SNI target |

## Build

```sh
docker build -t sing-box-deploy .
docker run -e UUID=... -e WS_PATH=/... -e PORT=8080 -p 8080:8080 sing-box-deploy
```

## Notes

- TLS is terminated by the platform (VLESS + WebSocket mode); the container
  itself listens on plain WS.
- Never commit a rendered `config.json` or any UUID / private key to this repo.
