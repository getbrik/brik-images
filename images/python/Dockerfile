# brik-runner-python - Python with Brik prerequisites
ARG VERSION=3.12
FROM python:${VERSION}-slim

ARG YQ_VERSION=v4.52.5
ARG JQ_VERSION=1.8.1

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-python"
LABEL org.opencontainers.image.description="Brik CI runner with Python"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION}

COPY scripts/install-brik.sh /tmp/install-brik.sh
RUN chmod +x /tmp/install-brik.sh && /tmp/install-brik.sh && rm /tmp/install-brik.sh

# Verify prerequisites + stack
RUN yq --version && jq --version && python3 --version && pip --version
