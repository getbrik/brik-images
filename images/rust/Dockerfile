# brik-runner-rust - Rust with Brik prerequisites
ARG VERSION=1
FROM rust:${VERSION}-slim-bookworm

ARG YQ_VERSION=v4.44.1
ARG JQ_VERSION=1.7.1

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-rust"
LABEL org.opencontainers.image.description="Brik CI runner with Rust"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION}

COPY scripts/install-brik.sh /tmp/install-brik.sh
RUN chmod +x /tmp/install-brik.sh && /tmp/install-brik.sh && rm /tmp/install-brik.sh

# Verify prerequisites + stack
RUN yq --version && jq --version && rustc --version && cargo --version
