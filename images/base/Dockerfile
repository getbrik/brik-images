# brik-runner-base - Alpine with Brik prerequisites
ARG VERSION=3.23
FROM alpine:${VERSION}

ARG YQ_VERSION=v4.52.5
ARG JQ_VERSION=1.8.1

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-base"
LABEL org.opencontainers.image.description="Brik CI runner base image with bash, yq, jq, git"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

RUN apk add --no-cache bash git curl ca-certificates

ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION}

COPY scripts/install-brik.sh /tmp/install-brik.sh
RUN chmod +x /tmp/install-brik.sh && /tmp/install-brik.sh && rm /tmp/install-brik.sh

# Verify prerequisites
RUN yq --version && jq --version && git --version && bash --version
