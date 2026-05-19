# brik-runner-scanner - Security scanning tools (static Go binaries)
# Contains: grype, syft, osv-scanner, hadolint, gitleaks, trufflehog, dockle
ARG VERSION=1
FROM alpine:3.23

ARG YQ_VERSION
ARG JQ_VERSION
ARG GRYPE_VERSION
ARG SYFT_VERSION
ARG OSV_SCANNER_VERSION
ARG HADOLINT_VERSION
ARG GITLEAKS_VERSION
ARG TRUFFLEHOG_VERSION
ARG DOCKLE_VERSION
ARG CYCLONEDX_CLI_VERSION
ARG DOCKER_BUILDX_VERSION

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-scanner"
LABEL org.opencontainers.image.description="Brik CI runner with scanning tools (grype, syft, osv-scanner, hadolint, gitleaks, trufflehog, dockle, cyclonedx-cli)"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

# Base dependencies (no Python, no Ruby)
RUN apk add --no-cache bash git curl ca-certificates \
    && rm -rf /var/cache/apk/*

# cyclonedx-cli (.NET self-contained on amd64) needs invariant globalization
# at runtime. Setting it as ENV in the image keeps the cli usable from any
# downstream brik runtime call without per-invocation env wiring.
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Brik prerequisites (yq, jq, git, docker-cli)
ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION} \
    DOCKER_BUILDX_VERSION=${DOCKER_BUILDX_VERSION}

COPY scripts/install-brik-prereqs.sh /tmp/install-brik-prereqs.sh
RUN chmod +x /tmp/install-brik-prereqs.sh && /tmp/install-brik-prereqs.sh && rm /tmp/install-brik-prereqs.sh

# Scanner tools - all static Go binaries
ENV GRYPE_VERSION=${GRYPE_VERSION} \
    SYFT_VERSION=${SYFT_VERSION} \
    OSV_SCANNER_VERSION=${OSV_SCANNER_VERSION} \
    HADOLINT_VERSION=${HADOLINT_VERSION} \
    GITLEAKS_VERSION=${GITLEAKS_VERSION} \
    TRUFFLEHOG_VERSION=${TRUFFLEHOG_VERSION} \
    DOCKLE_VERSION=${DOCKLE_VERSION} \
    CYCLONEDX_CLI_VERSION=${CYCLONEDX_CLI_VERSION}

COPY scripts/install-scanner-tools.sh /tmp/install-scanner-tools.sh
RUN chmod +x /tmp/install-scanner-tools.sh && /tmp/install-scanner-tools.sh \
    && rm -rf /tmp/* /var/cache/apk/* \
    && echo "brik-runner-scanner" > /.brik-runner \
    && yq --version && jq --version && git --version && bash --version \
    && grype version \
    && syft version \
    && osv-scanner --version \
    && hadolint --version \
    && gitleaks version \
    && trufflehog --version \
    && dockle --version \
    && (test -x /usr/local/bin/cyclonedx-cli && cyclonedx-cli --version || echo "cyclonedx-cli skipped (no upstream musl-arm64); jq fallback handles SBOM merge")
