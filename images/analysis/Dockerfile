# brik-runner-analysis - Full analysis tools (Python + Ruby, multi-stage)
# Contains: semgrep, checkov, scancode-toolkit, license_finder
ARG VERSION

# ---------------------------------------------------------------------------
# Stage 1: builder - install Python/Ruby tools with dev dependencies
# ---------------------------------------------------------------------------
FROM alpine:3.24 AS builder

RUN apk add --no-cache \
    bash \
    python3 py3-pip py3-setuptools python3-dev \
    ruby ruby-dev build-base \
    libarchive libmagic file \
    icu-libs icu-dev pkgconf \
    curl ca-certificates \
    && rm -rf /var/cache/apk/*

# Snapshot /usr/bin before installing tools (to diff later)
RUN ls /usr/bin > /tmp/bin-before.txt

ARG SEMGREP_VERSION
ARG CHECKOV_VERSION
ARG LICENSE_FINDER_VERSION
ARG SCANCODE_VERSION

ENV SEMGREP_VERSION=${SEMGREP_VERSION} \
    CHECKOV_VERSION=${CHECKOV_VERSION} \
    LICENSE_FINDER_VERSION=${LICENSE_FINDER_VERSION} \
    SCANCODE_VERSION=${SCANCODE_VERSION}

COPY scripts/install-analysis-tools.sh /tmp/install-analysis-tools.sh
RUN chmod +x /tmp/install-analysis-tools.sh && /tmp/install-analysis-tools.sh

# Collect all new scripts added by pip/gem into /installed-bin
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir -p /installed-bin \
    && comm -13 /tmp/bin-before.txt <(ls /usr/bin) | while read -r f; do \
         cp "/usr/bin/$f" /installed-bin/; \
       done

# Stage the Python site-packages at a fixed, version-agnostic path. The Alpine
# Python minor version moves with the base image (3.12 on Alpine 3.23, 3.14 on
# 3.24), so the final stage must not hardcode it.
RUN cp -a "$(ls -d /usr/lib/python3.*/site-packages | head -1)" /opt/py-site-packages

# ---------------------------------------------------------------------------
# Stage 2: final - runtime only (no dev deps, no build-base)
# ---------------------------------------------------------------------------
FROM alpine:3.24

ARG VERSION
ARG YQ_VERSION
ARG JQ_VERSION
ARG SEMGREP_VERSION
ARG CHECKOV_VERSION
ARG LICENSE_FINDER_VERSION
ARG SCANCODE_VERSION
ARG DOCKER_BUILDX_VERSION

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-analysis"
LABEL org.opencontainers.image.description="Brik CI runner with analysis tools (semgrep, checkov, license_finder, scancode)"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

# Runtime dependencies only (no -dev packages, no build-base)
RUN apk add --no-cache \
    bash git curl ca-certificates \
    python3 py3-setuptools \
    ruby \
    libarchive libmagic file \
    icu-libs \
    && rm -rf /var/cache/apk/*

# Point ScanCode extractcode/typecode at system native libs
ENV EXTRACTCODE_LIBARCHIVE_PATH=/usr/lib/libarchive.so.13 \
    TYPECODE_LIBMAGIC_PATH=/usr/lib/libmagic.so.1 \
    TYPECODE_LIBMAGIC_DB_PATH=/usr/share/file/misc/magic.mgc

# Brik prerequisites (yq, jq, git, docker-cli)
ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION} \
    DOCKER_BUILDX_VERSION=${DOCKER_BUILDX_VERSION}

COPY scripts/install-brik-prereqs.sh /tmp/install-brik-prereqs.sh
RUN chmod +x /tmp/install-brik-prereqs.sh && /tmp/install-brik-prereqs.sh && rm /tmp/install-brik-prereqs.sh

# Python site-packages from the builder, staged at a fixed path and exposed via
# PYTHONPATH so this stays correct across Alpine Python version bumps.
COPY --from=builder /opt/py-site-packages /opt/py-site-packages
ENV PYTHONPATH=/opt/py-site-packages
# Copy all pip/gem entry-point scripts added during install
COPY --from=builder /installed-bin/ /usr/bin/

# Copy Ruby gems from builder
COPY --from=builder /usr/lib/ruby/gems /usr/lib/ruby/gems

# Verify all tools work
RUN echo "brik-runner-analysis" > /.brik-runner \
    && yq --version && jq --version && git --version && bash --version \
    && semgrep --version \
    && checkov --version \
    && license_finder version \
    && scancode --version
