# Default version for NodeJS and Alpine Linux
FROM node:${NODE_VERSION}-alpine AS node
FROM alpine:${ALPINE_VERSION}

# set version for Dockerrize
ENV DOCKERIZE_VERSION v0.6.1

# set version for s6 overlay
ARG S6_OVERLAY_VERSION="3.1.5.0"
ARG S6_OVERLAY_ARCH="x86_64"

# add Dockerize
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Install OS Dependencies
RUN \
  apk add --no-cache --virtual=build-dependencies \
  tar && \
  apk add --no-cache \
  bash \
  curl \
  make \
  gcc \
  g++ \
  nginx \
  && mkdir -p /etc/nginx \
  && touch /var/log/nginx/error.log \
  && rm -Rf /etc/nginx/nginx.conf \
  ca-certificates \
  coreutils \
  tzdata && \
  apk add --no-cache \
  --repository http://nl.alpinelinux.org/alpine/edge/community \
  shadow && \
  # clean up
  apk del --purge \
  build-dependencies && \
  rm -rf \
  /tmp/*
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# add s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz

# add s6 optional symlinks
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz
WORKDIR /app
ADD rootfs /
