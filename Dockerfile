FROM caddy:2-alpine@sha256:5f5c8640aae01df9654968d946d8f1a56c497f1dd5c5cda4cf95ab7c14d58648
ARG REVISION=local
LABEL org.opencontainers.image.source="https://github.com/Derek-Sykes/xsolutions-website"
LABEL org.opencontainers.image.revision=$REVISION
COPY Caddyfile /etc/caddy/Caddyfile
COPY Caddyfile.local /etc/caddy/Caddyfile.local
COPY xsolutions-site/ /srv/
RUN printf '{"revision":"%s"}\n' "$REVISION" > /srv/version.json
HEALTHCHECK --interval=5s --timeout=3s --start-period=10s --retries=12 CMD wget -q -O /dev/null http://127.0.0.1:8081/version.json || exit 1
