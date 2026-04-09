# brik-runner-security - Security scanning tools for Brik CI/CD
ARG VERSION=1
FROM alpine:3.23

ARG YQ_VERSION=v4.52.5
ARG JQ_VERSION=1.8.1
ARG GITLEAKS_VERSION=8.24.0
ARG TRUFFLEHOG_VERSION=3.88.26
ARG GRYPE_VERSION=0.92.0
ARG SYFT_VERSION=1.22.0
ARG OSV_SCANNER_VERSION=2.0.1
ARG DOCKLE_VERSION=0.4.15

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-security"
LABEL org.opencontainers.image.description="Brik CI runner with security scanning tools (gitleaks, trufflehog, grype, syft, osv-scanner, dockle)"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

# Base dependencies
RUN apk add --no-cache bash git curl ca-certificates

# Brik prerequisites (yq, jq, git, docker-cli)
ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION}

COPY scripts/install-brik-prereqs.sh /tmp/install-brik-prereqs.sh
RUN chmod +x /tmp/install-brik-prereqs.sh && /tmp/install-brik-prereqs.sh && rm /tmp/install-brik-prereqs.sh

# Security tools - pass versions as env vars for install script
ENV GITLEAKS_VERSION=${GITLEAKS_VERSION} \
    TRUFFLEHOG_VERSION=${TRUFFLEHOG_VERSION} \
    GRYPE_VERSION=${GRYPE_VERSION} \
    SYFT_VERSION=${SYFT_VERSION} \
    OSV_SCANNER_VERSION=${OSV_SCANNER_VERSION} \
    DOCKLE_VERSION=${DOCKLE_VERSION}

COPY scripts/install-security-tools.sh /tmp/install-security-tools.sh
RUN chmod +x /tmp/install-security-tools.sh && /tmp/install-security-tools.sh \
    && rm -rf /tmp/* /var/cache/apk/* \
    && echo "brik-runner-security" > /.brik-runner \
    && yq --version && jq --version && git --version && bash --version \
    && gitleaks version \
    && trufflehog --version \
    && grype version \
    && syft version \
    && osv-scanner --version \
    && dockle --version
