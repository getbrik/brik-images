# brik-runner-security - Security scanning tools for Brik CI/CD
ARG VERSION=1
FROM alpine:3.23

ARG YQ_VERSION=v4.52.5
ARG JQ_VERSION=1.8.1

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

COPY scripts/install-brik.sh /tmp/install-brik.sh
RUN chmod +x /tmp/install-brik.sh && /tmp/install-brik.sh && rm /tmp/install-brik.sh

# Security tools
COPY scripts/install-security-tools.sh /tmp/install-security-tools.sh
RUN chmod +x /tmp/install-security-tools.sh && /tmp/install-security-tools.sh && rm /tmp/install-security-tools.sh

# Cleanup
RUN rm -rf /var/cache/apk/* /tmp/*

# Mark as brik-runner image
RUN echo "brik-runner-security" > /.brik-runner

# Verify all tools
RUN yq --version && jq --version && git --version && bash --version \
    && gitleaks version \
    && trufflehog --version \
    && grype version \
    && syft version \
    && osv-scanner --version \
    && dockle --version
