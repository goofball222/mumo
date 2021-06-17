FROM python:2-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL \
    org.opencontainers.image.vendor="The Goofball - goofball222@gmail.com" \
    org.opencontainers.image.url="https://github.com/goofball222/mumo" \
    org.opencontainers.image.title="Mumble/Murmur Server Mumo Script" \
    org.opencontainers.image.description="Mumble/Murmur Server Mumo Script" \
    org.opencontainers.image.version=$VERSION \
    org.opencontainers.image.source="https://github.com/goofball222/mumo" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.licenses="Apache-2.0"

ENV \
    DEBUG=false \
    MUMO_OPTS= \
    PGID=999 \
    PUID=999 \
    RUN_CHOWN=true \
    RUNAS_UID0=false

WORKDIR /opt/mumo

COPY root /

RUN set -x \
    && delgroup ping \
    && addgroup -g $PGID mumo \
    && adduser -D -G mumo -u $PUID mumo \
    && apk add -q --no-cache --virtual .build-deps \
        bzip2-dev g++ git openssl-dev \
    && apk add -q --no-cache \
        bash libstdc++ openssl shadow su-exec tzdata \
    && pip install --global-option=build_ext --global-option="-D__USE_UNIX98" zeroc-ice \
    && git clone https://github.com/mumble-voip/mumo.git . \
    && bash -c 'mkdir -p {config,log}' \
    && mv /opt/mumo/mumo.ini /opt/mumo/mumo.ini-default \
    && chown -R mumo:mumo /opt/mumo \
    && apk del -q .build-deps \
    && rm -rf /tmp/* /var/cache/apk/* \
    && find /usr/local -depth \
             \( \
                 \( -type d -a \( -name test -o -name tests \) \) \
                 -o \
                 \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
             \) -exec rm -rf '{}' +;

VOLUME ["/opt/mumo/config","/opt/mumo/log"]

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["mumo"]
