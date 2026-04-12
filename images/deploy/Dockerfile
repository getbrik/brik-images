# brik-runner-deploy - Deploy tools for Brik CI/CD pipelines
# Includes: docker compose, ssh, rsync, helm, kubectl, argocd CLI
FROM ghcr.io/getbrik/brik-runner-base:latest

ARG HELM_VERSION=v4.1.3
ARG KUBECTL_VERSION=v1.35.3
ARG ARGOCD_VERSION=v3.3.6

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-deploy"
LABEL org.opencontainers.image.description="Brik CI runner with deploy tools (compose, ssh, rsync, helm, kubectl, argocd)"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

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

# Verify all deploy tools
RUN docker compose version \
    && ssh -V \
    && rsync --version | head -1 \
    && helm version --short \
    && kubectl version --client --short 2>/dev/null || kubectl version --client \
    && argocd version --client --short 2>/dev/null || argocd version --client
