#!/usr/bin/env bash
# install-quality-lite-tools.sh - Install lightweight quality tools (static binaries).
#
# Installs: grype, syft, osv-scanner, hadolint
# No Python, no Ruby -- binary downloads only.
# Multi-arch aware (amd64/arm64).

set -euo pipefail

# Tool versions (pinned for reproducibility)
GRYPE_VERSION="${GRYPE_VERSION:-0.110.0}"
SYFT_VERSION="${SYFT_VERSION:-1.42.4}"
OSV_SCANNER_VERSION="${OSV_SCANNER_VERSION:-2.3.5}"
HADOLINT_VERSION="${HADOLINT_VERSION:-2.14.0}"

log() { printf '[install-quality-lite-tools] %s\n' "$*"; }

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
# Go binary tools
# ---------------------------------------------------------------------------

install_osv_scanner() {
    log "installing osv-scanner ${OSV_SCANNER_VERSION} (${ARCH})"
    local url="https://github.com/google/osv-scanner/releases/download/v${OSV_SCANNER_VERSION}/osv-scanner_linux_${ARCH}"
    curl -sSL -o /usr/local/bin/osv-scanner "$url"
    chmod +x /usr/local/bin/osv-scanner
    osv-scanner --version
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

install_hadolint() {
    log "installing hadolint ${HADOLINT_VERSION} (${ARCH})"
    local arch_suffix="${ARCH}"
    [[ "$ARCH" == "amd64" ]] && arch_suffix="x86_64"
    local url="https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-${arch_suffix}"
    curl -sSL -o /usr/local/bin/hadolint "$url"
    chmod +x /usr/local/bin/hadolint
    hadolint --version
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    log "starting quality-lite tools installation"
    log "  ARCH=${ARCH}"

    install_grype
    install_syft
    install_osv_scanner
    install_hadolint

    log "all quality-lite tools installed successfully"
}

main "$@"
