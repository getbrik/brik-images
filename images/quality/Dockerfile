# brik-runner-quality - Quality scanning tools for Brik CI/CD
ARG VERSION=1
FROM alpine:3.23

ARG YQ_VERSION=v4.52.5
ARG JQ_VERSION=1.8.1
ARG SEMGREP_VERSION=1.116.0
ARG OSV_SCANNER_VERSION=2.0.1
ARG GRYPE_VERSION=0.92.0
ARG SYFT_VERSION=1.22.0
ARG CHECKOV_VERSION=3.2.400
ARG HADOLINT_VERSION=2.12.0
ARG LICENSE_FINDER_VERSION=7.2.1
ARG SCANCODE_VERSION=32.4.0

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-quality"
LABEL org.opencontainers.image.description="Brik CI runner with quality scanning tools (semgrep, osv-scanner, grype, syft, checkov, hadolint, license_finder, scancode)"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

# Base dependencies
RUN apk add --no-cache bash git curl ca-certificates \
    python3 py3-pip py3-setuptools python3-dev \
    ruby ruby-dev build-base \
    libarchive libmagic file \
    icu-libs icu-dev pkgconf \
    && rm -rf /var/cache/apk/*

# Point ScanCode extractcode/typecode at system native libs (no musl wheels available)
ENV EXTRACTCODE_LIBARCHIVE_PATH=/usr/lib/libarchive.so.13 \
    TYPECODE_LIBMAGIC_PATH=/usr/lib/libmagic.so.1 \
    TYPECODE_LIBMAGIC_DB_PATH=/usr/share/file/misc/magic.mgc

# Brik prerequisites (yq, jq, git, docker-cli)
ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION}

COPY scripts/install-brik.sh /tmp/install-brik.sh
RUN chmod +x /tmp/install-brik.sh && /tmp/install-brik.sh && rm /tmp/install-brik.sh

# Quality tools - pass versions as env vars for install script
ENV SEMGREP_VERSION=${SEMGREP_VERSION} \
    OSV_SCANNER_VERSION=${OSV_SCANNER_VERSION} \
    GRYPE_VERSION=${GRYPE_VERSION} \
    SYFT_VERSION=${SYFT_VERSION} \
    CHECKOV_VERSION=${CHECKOV_VERSION} \
    HADOLINT_VERSION=${HADOLINT_VERSION} \
    LICENSE_FINDER_VERSION=${LICENSE_FINDER_VERSION} \
    SCANCODE_VERSION=${SCANCODE_VERSION}

COPY scripts/install-quality-tools.sh /tmp/install-quality-tools.sh
RUN chmod +x /tmp/install-quality-tools.sh && /tmp/install-quality-tools.sh \
    && apk del build-base ruby-dev python3-dev icu-dev pkgconf \
    && rm -rf /var/cache/apk/* /root/.cache /tmp/* \
    && echo "brik-runner-quality" > /.brik-runner \
    && yq --version && jq --version && git --version && bash --version \
    && semgrep --version \
    && osv-scanner --version \
    && grype version \
    && syft version \
    && checkov --version \
    && hadolint --version \
    && license_finder version \
    && scancode --version
