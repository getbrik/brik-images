# brik-runner-deploy - Deploy tools for Brik CI/CD pipelines
# Includes: docker compose, ssh, rsync, helm, kubectl, argocd CLI, cosign, oras
# hadolint ignore=DL3007
FROM ghcr.io/getbrik/brik-runner-base:latest

ARG HELM_VERSION
ARG KUBECTL_VERSION
ARG ARGOCD_VERSION
ARG COSIGN_VERSION
ARG ORAS_VERSION

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-deploy"
LABEL org.opencontainers.image.description="Brik CI runner with deploy tools (compose, ssh, rsync, helm, kubectl, argocd, cosign, oras)"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# Alpine packages: docker compose plugin, ssh client, rsync
RUN apk add --no-cache docker-cli-compose openssh-client rsync

# Detect architecture for multi-arch binary downloads
RUN ARCH="$(uname -m)" \
    && case "$ARCH" in \
        x86_64)  ARCH_GO="amd64" ;; \
        aarch64) ARCH_GO="arm64" ;; \
        arm64)   ARCH_GO="arm64" ;; \
        *)       echo "unsupported arch: $ARCH" && exit 1 ;; \
    esac \
    # helm
    && curl -sSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH_GO}.tar.gz" \
       | tar xz -C /usr/local/bin --strip-components=1 "linux-${ARCH_GO}/helm" \
    # kubectl
    && curl -sSL -o /usr/local/bin/kubectl \
       "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH_GO}/kubectl" \
    && chmod +x /usr/local/bin/kubectl \
    # argocd
    && curl -sSL -o /usr/local/bin/argocd \
       "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${ARCH_GO}" \
    && chmod +x /usr/local/bin/argocd

# Evidence tools (cosign, oras): verify the image signature/attestation before
# deploying (fail-closed CD preflight) and read the referrer graph.
ENV COSIGN_VERSION=${COSIGN_VERSION} \
    ORAS_VERSION=${ORAS_VERSION}

COPY scripts/install-evidence-tools.sh /tmp/install-evidence-tools.sh
RUN chmod +x /tmp/install-evidence-tools.sh && /tmp/install-evidence-tools.sh && rm /tmp/install-evidence-tools.sh

# Verify all deploy tools
# hadolint ignore=DL3001
RUN docker compose version \
    && ssh -V \
    && rsync --version \
    && helm version --short \
    && kubectl version --client \
    && argocd version --client \
    && cosign version \
    && oras version
