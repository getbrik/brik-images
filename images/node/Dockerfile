# brik-runner-node - Node.js with Brik prerequisites
ARG VERSION=22
FROM node:${VERSION}-slim

ARG YQ_VERSION=v4.44.1
ARG JQ_VERSION=1.7.1

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-node"
LABEL org.opencontainers.image.description="Brik CI runner with Node.js"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION}

COPY scripts/install-brik.sh /tmp/install-brik.sh
RUN chmod +x /tmp/install-brik.sh && /tmp/install-brik.sh && rm /tmp/install-brik.sh

# Verify prerequisites + stack
RUN yq --version && jq --version && node --version && npm --version
