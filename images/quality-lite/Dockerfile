# brik-runner-quality-lite - Lightweight quality scanning tools (static binaries)
ARG VERSION=1
FROM alpine:3.23

ARG YQ_VERSION=v4.52.5
ARG JQ_VERSION=1.8.1
ARG GRYPE_VERSION=0.110.0
ARG SYFT_VERSION=1.42.4
ARG OSV_SCANNER_VERSION=2.3.5
ARG HADOLINT_VERSION=2.14.0

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-quality-lite"
LABEL org.opencontainers.image.description="Brik CI runner with lightweight quality tools (grype, syft, osv-scanner, hadolint)"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

# Base dependencies (no Python, no Ruby)
RUN apk add --no-cache bash git curl ca-certificates \
    && rm -rf /var/cache/apk/*

# Brik prerequisites (yq, jq, git, docker-cli)
ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION}

COPY scripts/install-brik-prereqs.sh /tmp/install-brik-prereqs.sh
RUN chmod +x /tmp/install-brik-prereqs.sh && /tmp/install-brik-prereqs.sh && rm /tmp/install-brik-prereqs.sh

# Quality-lite tools - static binaries only
ENV GRYPE_VERSION=${GRYPE_VERSION} \
    SYFT_VERSION=${SYFT_VERSION} \
    OSV_SCANNER_VERSION=${OSV_SCANNER_VERSION} \
    HADOLINT_VERSION=${HADOLINT_VERSION}

COPY scripts/install-quality-lite-tools.sh /tmp/install-quality-lite-tools.sh
RUN chmod +x /tmp/install-quality-lite-tools.sh && /tmp/install-quality-lite-tools.sh \
    && rm -rf /tmp/* \
    && echo "brik-runner-quality-lite" > /.brik-runner \
    && yq --version && jq --version && git --version && bash --version \
    && grype version \
    && syft version \
    && osv-scanner --version \
    && hadolint --version
