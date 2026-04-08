# brik-runner-quality - Quality scanning tools for Brik CI/CD
ARG VERSION=1
FROM alpine:3.23

ARG YQ_VERSION=v4.52.5
ARG JQ_VERSION=1.8.1

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-quality"
LABEL org.opencontainers.image.description="Brik CI runner with quality scanning tools (semgrep, osv-scanner, grype, syft, checkov, hadolint, license_finder, scancode)"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

# Base dependencies
RUN apk add --no-cache bash git curl ca-certificates \
    python3 py3-pip py3-setuptools \
    ruby ruby-dev build-base \
    && rm -rf /var/cache/apk/*

# Brik prerequisites (yq, jq, git, docker-cli)
ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION}

COPY scripts/install-brik.sh /tmp/install-brik.sh
RUN chmod +x /tmp/install-brik.sh && /tmp/install-brik.sh && rm /tmp/install-brik.sh

# Quality tools
COPY scripts/install-quality-tools.sh /tmp/install-quality-tools.sh
RUN chmod +x /tmp/install-quality-tools.sh && /tmp/install-quality-tools.sh && rm /tmp/install-quality-tools.sh

# Cleanup build dependencies
RUN apk del build-base ruby-dev && rm -rf /var/cache/apk/* /root/.cache /tmp/*

# Mark as brik-runner image
RUN echo "brik-runner-quality" > /.brik-runner

# Verify all tools
RUN yq --version && jq --version && git --version && bash --version \
    && semgrep --version \
    && osv-scanner --version \
    && grype version \
    && syft version \
    && checkov --version \
    && hadolint --version \
    && license_finder version \
    && scancode --version
