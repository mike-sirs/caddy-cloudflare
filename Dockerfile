FROM golang:1.24-alpine3.20 AS caddy_builder

ENV VAR_XCADDY=0.4.4
ENV VAR_CADDY=2.10.0-beta.4
ENV XCADDY_SKIP_CLEANUP 1
# Sets capabilities for output caddy binary to be able to bind to privileged ports
ENV XCADDY_SETCAP 1

RUN apk update && \
    apk add --no-cache build-base wget git && \
    wget https://github.com/caddyserver/xcaddy/releases/download/v${VAR_XCADDY}/xcaddy_${VAR_XCADDY}_linux_amd64.tar.gz && \
    tar -xzvf xcaddy_${VAR_XCADDY}_linux_amd64.tar.gz -C /usr/local/bin && \
    chmod +x /usr/local/bin/xcaddy && \
    CGO_ENABLED=1 xcaddy build v${VAR_CADDY} \
    --with github.com/caddy-dns/cloudflare

FROM alpine:edge

RUN echo "net.core.rmem_max=2500000" > /etc/sysctl.conf

COPY --from=caddy_builder --link /go/caddy /usr/bin/caddy

WORKDIR /var/www/public

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
