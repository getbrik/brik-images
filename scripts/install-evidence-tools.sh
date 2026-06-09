#!/usr/bin/env bash
# install-evidence-tools.sh - Install supply-chain evidence tools into an image.
#
# Installs: cosign, oras. Both are static Go binaries from GitHub releases,
# multi-arch aware (amd64/arm64).
#
# Role in the CI/CD chain:
#   - cosign signs the published image digest and attaches SBOM + SLSA
#     provenance as signed OCI 1.1 referrers (CI flow), and verifies those
#     attestations before a deploy (CD flow, fail-closed preflight).
#   - oras reads and copies the referrer graph (discover at verify time;
#     image + referrers copy at promotion).
# The scanner image needs both to sign; the deploy image needs both to verify.

set -euo pipefail

# Tool versions arrive from the Docker build (ARG -> ENV) and originate in
# versions.json (the single source of truth). Failing fast here surfaces a
# missing wire-up in generate-bake.sh or the Dockerfile instead of silently
# baking a stale binary.
: "${COSIGN_VERSION:?COSIGN_VERSION must be set (passed from versions.json via Docker ARG)}"
: "${ORAS_VERSION:?ORAS_VERSION must be set (passed from versions.json via Docker ARG)}"

log() { printf '[install-evidence-tools] %s\n' "$*"; }

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

install_cosign() {
    log "installing cosign ${COSIGN_VERSION} (${ARCH})"
    # cosign ships a bare binary per platform: cosign-linux-<arch>.
    local url="https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-${ARCH}"
    curl -sSL -o /usr/local/bin/cosign "$url"
    chmod +x /usr/local/bin/cosign
    cosign version
}

install_oras() {
    log "installing oras ${ORAS_VERSION} (${ARCH})"
    # oras ships a tarball: oras_<version>_linux_<arch>.tar.gz containing `oras`.
    local url="https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_${ARCH}.tar.gz"
    curl -sSL "$url" | tar xz -C /usr/local/bin oras
    chmod +x /usr/local/bin/oras
    oras version
}

main() {
    log "starting evidence tools installation"
    log "  ARCH=${ARCH}"

    install_cosign
    install_oras

    log "all evidence tools installed successfully"
}

main "$@"
