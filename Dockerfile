FROM spritsail/fivem as base

FROM node:16-alpine
    # Copy filesystem portions from spritsail/fivem
    COPY --from=base / /

    # Grab rcon client for iterative development
    RUN \
        wget https://github.com/icedream/icecon/releases/download/v1.0.0/icecon_linux_i386 -O /usr/bin/rcon && \
        chmod +x /usr/bin/rcon && \
        mkdir -p /.npm && \
        chown -R 1000:1000 /.npm

    USER 1000

    # Re-establish similar env settings from spritsail/fivem
    WORKDIR /config
    EXPOSE 30120
    EXPOSE 40120
    ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]
    CMD [""]
