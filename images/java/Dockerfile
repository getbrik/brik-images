# brik-runner-java - Java + Maven with Brik prerequisites
ARG VERSION=21
FROM eclipse-temurin:${VERSION}-jdk-jammy

ARG YQ_VERSION=v4.53.2
ARG JQ_VERSION=1.8.1

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-java"
LABEL org.opencontainers.image.description="Brik CI runner with Java and Maven"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

# Install Maven
RUN apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends maven \
    && rm -rf /var/lib/apt/lists/*

ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION}

COPY scripts/install-brik-prereqs.sh /tmp/install-brik-prereqs.sh
RUN chmod +x /tmp/install-brik-prereqs.sh && /tmp/install-brik-prereqs.sh && rm /tmp/install-brik-prereqs.sh

# Mark as brik-runner image (detected by setup.sh to skip prerequisite install)
RUN echo "brik-runner" > /.brik-runner

# Verify prerequisites + stack
RUN yq --version && jq --version && java --version && mvn --version
