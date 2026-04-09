#!/usr/bin/env bash
# install-security-tools.sh - Install security scanning tools into a Docker image.
#
# Installs: gitleaks, trufflehog, grype, syft, osv-scanner, dockle
# All Go binaries from GitHub releases. Multi-arch aware (amd64/arm64).

set -euo pipefail

# Tool versions (pinned for reproducibility)
GITLEAKS_VERSION="${GITLEAKS_VERSION:-8.24.0}"
TRUFFLEHOG_VERSION="${TRUFFLEHOG_VERSION:-3.88.26}"
GRYPE_VERSION="${GRYPE_VERSION:-0.92.0}"
SYFT_VERSION="${SYFT_VERSION:-1.22.0}"
OSV_SCANNER_VERSION="${OSV_SCANNER_VERSION:-2.0.1}"
DOCKLE_VERSION="${DOCKLE_VERSION:-0.4.15}"

log() { printf '[install-security-tools] %s\n' "$*"; }

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

ARCH="$(detect_arch)"

# ---------------------------------------------------------------------------
# Tool installers
# ---------------------------------------------------------------------------

install_gitleaks() {
    log "installing gitleaks ${GITLEAKS_VERSION} (${ARCH})"
    local arch_suffix="${ARCH}"
    [[ "$ARCH" == "amd64" ]] && arch_suffix="x64"
    local url="https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${arch_suffix}.tar.gz"
    curl -sSL "$url" | tar xz -C /usr/local/bin gitleaks
    chmod +x /usr/local/bin/gitleaks
    gitleaks version
}

install_trufflehog() {
    log "installing trufflehog ${TRUFFLEHOG_VERSION} (${ARCH})"
    local url="https://github.com/trufflesecurity/trufflehog/releases/download/v${TRUFFLEHOG_VERSION}/trufflehog_${TRUFFLEHOG_VERSION}_linux_${ARCH}.tar.gz"
    curl -sSL "$url" | tar xz -C /usr/local/bin trufflehog
    chmod +x /usr/local/bin/trufflehog
    trufflehog --version
}

install_grype() {
    log "installing grype ${GRYPE_VERSION} (${ARCH})"
    local url="https://github.com/anchore/grype/releases/download/v${GRYPE_VERSION}/grype_${GRYPE_VERSION}_linux_${ARCH}.tar.gz"
    curl -sSL "$url" | tar xz -C /usr/local/bin grype
    chmod +x /usr/local/bin/grype
    grype version
}

install_syft() {
    log "installing syft ${SYFT_VERSION} (${ARCH})"
    local url="https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_linux_${ARCH}.tar.gz"
    curl -sSL "$url" | tar xz -C /usr/local/bin syft
    chmod +x /usr/local/bin/syft
    syft version
}

install_osv_scanner() {
    log "installing osv-scanner ${OSV_SCANNER_VERSION} (${ARCH})"
    local url="https://github.com/google/osv-scanner/releases/download/v${OSV_SCANNER_VERSION}/osv-scanner_linux_${ARCH}"
    curl -sSL -o /usr/local/bin/osv-scanner "$url"
    chmod +x /usr/local/bin/osv-scanner
    osv-scanner --version
}

install_dockle() {
    log "installing dockle ${DOCKLE_VERSION} (${ARCH})"
    local arch_suffix="64bit"
    [[ "$ARCH" == "arm64" ]] && arch_suffix="ARM64"
    local url="https://github.com/goodwithtech/dockle/releases/download/v${DOCKLE_VERSION}/dockle_${DOCKLE_VERSION}_Linux-${arch_suffix}.tar.gz"
    curl -sSL "$url" | tar xz -C /usr/local/bin dockle
    chmod +x /usr/local/bin/dockle
    dockle --version
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    log "starting security tools installation"
    log "  ARCH=${ARCH}"

    install_gitleaks
    install_trufflehog
    install_grype
    install_syft
    install_osv_scanner
    install_dockle

    log "all security tools installed successfully"
}

main "$@"
