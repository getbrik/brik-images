# brik-runner-base - Alpine with Brik prerequisites
ARG VERSION
ARG JV_VERSION

# ---------------------------------------------------------------------------
# Stage 1: build jv (santhosh-tekuri/jsonschema CLI) from source.
# CGO_ENABLED=0 produces a static binary that runs on any Linux distro
# (Alpine musl, Debian/Ubuntu glibc) without runtime dependencies.
# Required because upstream releases ship asymmetric binaries: linux-arm64
# is static but linux-amd64 is glibc-dynamic, breaking Alpine amd64.
# cmd/jv is a separate Go module from the parent jsonschema library.
# Its tags follow `cmd/jv/v0.x.y`, independent of the library's `v6.x.y`.
# v0.7.0 is the latest published cmd/jv tag and pulls in
# jsonschema/v6 v6.0.1 transitively.
# ---------------------------------------------------------------------------
FROM golang:1.26-alpine AS jv-builder
ARG JV_VERSION
ENV CGO_ENABLED=0
RUN apk add --no-cache git \
 && go install -ldflags="-s -w" "github.com/santhosh-tekuri/jsonschema/cmd/jv@${JV_VERSION}" \
 && cp /go/bin/jv /jv

# ---------------------------------------------------------------------------
# Stage 2: brik-runner-base
# ---------------------------------------------------------------------------
FROM alpine:${VERSION}

ARG YQ_VERSION
ARG JQ_VERSION
ARG JV_VERSION
ARG DOCKER_BUILDX_VERSION
ARG GLOW_VERSION

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-base"
LABEL org.opencontainers.image.description="Brik CI runner base image with bash, yq, jq, jv, git, glow"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

RUN apk add --no-cache bash git curl ca-certificates

# glow is not packaged in Alpine main/community (only edge/testing,
# which is too volatile for a pinned base image). Install the upstream
# GitHub release tarball instead. The version is pinned via build-arg
# fed from versions.json (.tools.glow). curl + tar are split so a
# curl HTTP failure surfaces immediately (no piping into tar, which
# would silently succeed on truncated input).
RUN GLOW_VER="${GLOW_VERSION#v}" \
 && ARCH=$(uname -m) \
 && case "$ARCH" in \
        x86_64)  GARCH="x86_64" ;; \
        aarch64) GARCH="arm64"  ;; \
        *)       echo "unsupported arch: $ARCH" >&2; exit 1 ;; \
    esac \
 && curl -fsSL -o /tmp/glow.tar.gz "https://github.com/charmbracelet/glow/releases/download/v${GLOW_VER}/glow_${GLOW_VER}_Linux_${GARCH}.tar.gz" \
 && tar -xzf /tmp/glow.tar.gz -C /tmp \
 && install -m 0755 "/tmp/glow_${GLOW_VER}_Linux_${GARCH}/glow" /usr/local/bin/glow \
 && rm -rf "/tmp/glow.tar.gz" "/tmp/glow_${GLOW_VER}_Linux_${GARCH}"

ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION} \
    JV_VERSION=${JV_VERSION} \
    DOCKER_BUILDX_VERSION=${DOCKER_BUILDX_VERSION}

COPY scripts/install-brik-prereqs.sh /tmp/install-brik-prereqs.sh
RUN chmod +x /tmp/install-brik-prereqs.sh && /tmp/install-brik-prereqs.sh && rm /tmp/install-brik-prereqs.sh

# Install jv (JSON Schema validator), built statically in stage 1
COPY --from=jv-builder /jv /usr/local/bin/jv

# Mark as brik-runner image (detected by setup.sh to skip prerequisite install)
RUN echo "brik-runner" > /.brik-runner

# Verify prerequisites
RUN yq --version && jq --version && jv --version && git --version && bash --version && glow --version
