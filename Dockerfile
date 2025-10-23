FROM golang:1.25.3-alpine3.22 AS caddy_builder

ENV VAR_CADDY=2.10.2

RUN apk update && \
    apk add --no-cache build-base wget git
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
RUN xcaddy version && \
    CGO_ENABLED=1 xcaddy build v${VAR_CADDY} \
    --with github.com/caddy-dns/cloudflare@master \
    --with github.com/libdns/libdns@master
FROM alpine:edge

RUN echo "net.core.rmem_max=7500000" > /etc/sysctl.conf && \
    echo "net.core.wmem_max=7500000" >> /etc/sysctl.conf

COPY --from=caddy_builder --link /go/caddy /usr/bin/caddy

WORKDIR /var/www/public

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
