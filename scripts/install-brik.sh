#!/usr/bin/env bash
# install-brik.sh - Install Brik prerequisites into a Docker image.
#
# Installs: yq, jq, git, docker-cli (if missing).
# Multi-arch aware (amd64/arm64).
#
# The brik runtime itself is NOT included -- it is cloned at CI time
# by the shared library's before_script (decoupled release cycle).
#
# Environment variables (set via Dockerfile ARG):
#   YQ_VERSION    - yq version (default: v4.44.1)
#   JQ_VERSION    - jq version (default: 1.7.1)

set -euo pipefail

YQ_VERSION="${YQ_VERSION:-v4.52.5}"
JQ_VERSION="${JQ_VERSION:-1.8.1}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log() { printf '[install-brik] %s\n' "$*"; }

detect_arch() {
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64)  echo "amd64" ;;
        aarch64) echo "arm64" ;;
        arm64)   echo "arm64" ;;
        *)       echo "$arch" ;;
    esac
}

detect_pkg_manager() {
    local mgr
    for mgr in apt-get apk yum dnf; do
        if command -v "$mgr" >/dev/null 2>&1; then
            echo "$mgr"
            return 0
        fi
    done
    echo ""
}

# ---------------------------------------------------------------------------
# Install git if missing
# ---------------------------------------------------------------------------

install_git() {
    if command -v git >/dev/null 2>&1; then
        log "git already installed"
        return 0
    fi

    local mgr
    mgr="$(detect_pkg_manager)"
    case "$mgr" in
        apk)
            apk add --no-cache git
            ;;
        apt-get)
            apt-get update -qq && apt-get install -y -qq --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*
            ;;
        yum)
            yum install -y git && yum clean all
            ;;
        dnf)
            dnf install -y git && dnf clean all
            ;;
        *)
            log "ERROR: cannot install git - no package manager found"
            return 1
            ;;
    esac
    log "git installed"
}

# ---------------------------------------------------------------------------
# Install curl if missing
# ---------------------------------------------------------------------------

install_curl() {
    if command -v curl >/dev/null 2>&1; then
        return 0
    fi

    local mgr
    mgr="$(detect_pkg_manager)"
    case "$mgr" in
        apk)
            apk add --no-cache curl
            ;;
        apt-get)
            apt-get update -qq && apt-get install -y -qq --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*
            ;;
        yum)
            yum install -y curl && yum clean all
            ;;
        dnf)
            dnf install -y curl && dnf clean all
            ;;
        *)
            log "ERROR: cannot install curl - no package manager found"
            return 1
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Install yq
# ---------------------------------------------------------------------------

install_yq() {
    if command -v yq >/dev/null 2>&1; then
        log "yq already installed"
        return 0
    fi

    local arch os
    arch="$(detect_arch)"
    os="$(uname -s | tr '[:upper:]' '[:lower:]')"
    local url="https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_${os}_${arch}"

    log "installing yq ${YQ_VERSION} (${os}/${arch})"
    curl -sSL -o /usr/local/bin/yq "$url"
    chmod +x /usr/local/bin/yq
    yq --version
    log "yq installed"
}

# ---------------------------------------------------------------------------
# Install jq
# ---------------------------------------------------------------------------

install_jq() {
    if command -v jq >/dev/null 2>&1; then
        log "jq already installed"
        return 0
    fi

    local arch os
    arch="$(detect_arch)"
    os="$(uname -s | tr '[:upper:]' '[:lower:]')"
    [[ "$os" == "darwin" ]] && os="macos"
    local url="https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-${os}-${arch}"

    log "installing jq ${JQ_VERSION} (${os}/${arch})"
    curl -sSL -o /usr/local/bin/jq "$url"
    chmod +x /usr/local/bin/jq
    jq --version
    log "jq installed"
}

# ---------------------------------------------------------------------------
# Install Docker CLI (for container build/push in package stage)
# ---------------------------------------------------------------------------

install_docker_cli() {
    if command -v docker >/dev/null 2>&1; then
        log "docker already installed"
        return 0
    fi

    local mgr
    mgr="$(detect_pkg_manager)"
    case "$mgr" in
        apk)
            apk add --no-cache docker-cli
            ;;
        apt-get)
            # Detect distro (debian or ubuntu) for Docker repo
            local distro
            distro="$(. /etc/os-release && echo "${ID}")"
            case "$distro" in
                ubuntu|debian) ;;
                *) distro="debian" ;;
            esac
            apt-get update -qq \
                && apt-get install -y -qq --no-install-recommends \
                    ca-certificates curl gnupg \
                && install -m 0755 -d /etc/apt/keyrings \
                && curl -fsSL "https://download.docker.com/linux/${distro}/gpg" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
                && chmod a+r /etc/apt/keyrings/docker.gpg \
                && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${distro} $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
                && apt-get update -qq \
                && apt-get install -y -qq --no-install-recommends docker-ce-cli \
                && rm -rf /var/lib/apt/lists/*
            ;;
        yum)
            yum install -y docker-cli && yum clean all
            ;;
        dnf)
            dnf install -y docker-cli && dnf clean all
            ;;
        *)
            log "ERROR: cannot install docker-cli - no package manager found"
            return 1
            ;;
    esac
    log "docker-cli installed"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    log "starting Brik prerequisites installation"
    log "  YQ_VERSION=${YQ_VERSION}"
    log "  JQ_VERSION=${JQ_VERSION}"

    install_curl
    install_git
    install_yq
    install_jq
    install_docker_cli

    log "all Brik prerequisites installed successfully"
}

main "$@"
