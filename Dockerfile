# syntax=docker/dockerfile:1
# sing-box proxy — multi-stage build, latest stable release (linux/amd64)
# Runtime listens on $PORT (platform-assigned; entrypoint.sh renders the
# config from the template + env vars at startup). Runs as non-root
# (uid 10001). No credentials baked in: UUID/WS_PATH/PRIVATE_KEY are passed
# as environment variables by each platform app, so one repo serves all
# nodes and the repo itself contains no secrets.

FROM alpine:3.20 AS downloader
RUN apk add --no-cache curl ca-certificates tar
ARG SING_BOX_VERSION=latest
RUN set -eux; \
  if [ "$SING_BOX_VERSION" = "latest" ]; then \
    SING_BOX_VERSION="$(curl -fsSL https://api.github.com/repos/SagerNet/sing-box/releases/latest \
      | grep '"tag_name"' | head -1 | sed -E 's/.*"v?([^"]+)".*/\1/')"; \
  fi; \
  echo "sing-box ${SING_BOX_VERSION}"; \
  curl -fsSL -o /tmp/sing-box.tar.gz \
    "https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION}-linux-amd64.tar.gz"; \
  tar -xzf /tmp/sing-box.tar.gz -C /tmp; \
  mv "/tmp/sing-box-${SING_BOX_VERSION}-linux-amd64/sing-box" /usr/local/bin/sing-box; \
  chmod +x /usr/local/bin/sing-box; \
  /usr/local/bin/sing-box version

FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata \
  && adduser -D -u 10001 singbox
COPY --from=downloader /usr/local/bin/sing-box /usr/local/bin/sing-box
WORKDIR /app
COPY config-template.json /app/config-template.json
COPY config-reality.json /app/config-reality.json
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh \
  && chown -R singbox:singbox /app
USER singbox
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
