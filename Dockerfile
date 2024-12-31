FROM caddy:2.9.0-builder AS caddy_builder

RUN apk update && \
    apk add --no-cache build-base && \
    CGO_ENABLED=1 xcaddy build  \
    --with github.com/caddy-dns/cloudflare

FROM caddy:2.9.0

RUN echo "net.core.rmem_max=2500000" > /etc/sysctl.conf

COPY --from=caddy_builder --link /usr/bin/caddy /usr/bin/caddy

WORKDIR /var/www/public
