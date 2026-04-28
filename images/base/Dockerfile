# brik-runner-base - Alpine with Brik prerequisites
ARG VERSION=3.23@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659
ARG JV_VERSION=v6.0.2

# ---------------------------------------------------------------------------
# Stage 1: build jv (santhosh-tekuri/jsonschema CLI) from source.
# CGO_ENABLED=0 produces a static binary that runs on any Linux distro
# (Alpine musl, Debian/Ubuntu glibc) without runtime dependencies.
# Required because upstream releases ship asymmetric binaries: linux-arm64
# is static but linux-amd64 is glibc-dynamic, breaking Alpine amd64.
# ---------------------------------------------------------------------------
FROM golang:1.23-alpine AS jv-builder
ARG JV_VERSION
RUN apk add --no-cache git \
 && git clone --depth 1 --branch ${JV_VERSION} https://github.com/santhosh-tekuri/jsonschema /src
WORKDIR /src/cmd/jv
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /jv .

# ---------------------------------------------------------------------------
# Stage 2: brik-runner-base
# ---------------------------------------------------------------------------
FROM alpine:${VERSION}

ARG YQ_VERSION=v4.53.2
ARG JQ_VERSION=1.8.1
ARG JV_VERSION

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-base"
LABEL org.opencontainers.image.description="Brik CI runner base image with bash, yq, jq, jv, git"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

RUN apk add --no-cache bash git curl ca-certificates

ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION} \
    JV_VERSION=${JV_VERSION}

COPY scripts/install-brik-prereqs.sh /tmp/install-brik-prereqs.sh
RUN chmod +x /tmp/install-brik-prereqs.sh && /tmp/install-brik-prereqs.sh && rm /tmp/install-brik-prereqs.sh

# Install jv (JSON Schema validator), built statically in stage 1
COPY --from=jv-builder /jv /usr/local/bin/jv

# Mark as brik-runner image (detected by setup.sh to skip prerequisite install)
RUN echo "brik-runner" > /.brik-runner

# Verify prerequisites
RUN yq --version && jq --version && jv --version && git --version && bash --version
