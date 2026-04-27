# brik-runner-dotnet - .NET SDK with Brik prerequisites
ARG VERSION=10.0@sha256:f061e5a7532b36fa1d1b684857fe1f504ba92115b9934f154643266613c44c62
FROM mcr.microsoft.com/dotnet/sdk:${VERSION}

ARG YQ_VERSION=v4.53.2
ARG JQ_VERSION=1.8.1

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-dotnet"
LABEL org.opencontainers.image.description="Brik CI runner with .NET SDK"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION}

COPY scripts/install-brik-prereqs.sh /tmp/install-brik-prereqs.sh
RUN chmod +x /tmp/install-brik-prereqs.sh && /tmp/install-brik-prereqs.sh && rm /tmp/install-brik-prereqs.sh

# Mark as brik-runner image (detected by setup.sh to skip prerequisite install)
RUN echo "brik-runner" > /.brik-runner

# Verify prerequisites + stack
RUN yq --version && jq --version && dotnet --version
