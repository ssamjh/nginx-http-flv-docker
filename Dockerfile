ARG NGINX_VERSION=1.26.1
ARG NGINX_HTTP_FLV_VERSION=1.2.11

FROM alpine:3.20 AS base

RUN apk add --no-cache pcre openssl


FROM base AS build
ARG NGINX_VERSION
ARG NGINX_HTTP_FLV_VERSION

RUN apk add --no-cache build-base pcre-dev openssl-dev zlib-dev

WORKDIR /tmp
RUN \
    wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar xzf nginx-${NGINX_VERSION}.tar.gz && \
    wget https://github.com/winshining/nginx-http-flv-module/archive/v${NGINX_HTTP_FLV_VERSION}.tar.gz && \
    tar xzf v${NGINX_HTTP_FLV_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    ./configure --add-module=../nginx-http-flv-module-${NGINX_HTTP_FLV_VERSION} && \
    make && \
    make install && \
    cd .. && \
    rm -rf nginx-* v${NGINX_HTTP_FLV_VERSION}.tar.gz


FROM base AS release
COPY --from=build /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
RUN \
    apk add --no-cache pcre openssl && \
    rm -rf /var/cache/apk/* /tmp/*

EXPOSE 1935
EXPOSE 8080

CMD ["/usr/local/nginx/sbin/nginx"]
