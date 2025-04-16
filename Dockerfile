FROM golang:1.24-alpine AS caddy_builder

ENV VAR_XCADDY=0.4.4
ENV VAR_CADDY=2.10.0-beta.4

RUN apk update && \
    apk add --no-cache build-base wget git && \
    go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest && \
    xcaddy version && \
    CGO_ENABLED=1 xcaddy build v${VAR_CADDY} \
    --with github.com/caddy-dns/cloudflare

FROM alpine:edge

RUN echo "net.core.rmem_max=7500000" > /etc/sysctl.conf && \
    echo "net.core.wmem_max=7500000" >> /etc/sysctl.conf && \

COPY --from=caddy_builder --link /go/caddy /usr/bin/caddy

WORKDIR /var/www/public

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
