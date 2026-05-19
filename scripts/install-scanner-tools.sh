#!/usr/bin/env bash
# install-scanner-tools.sh - Install scanner tools into a Docker image.
#
# Installs: grype, syft, osv-scanner, hadolint, gitleaks, trufflehog, dockle, cyclonedx-cli
# All Go and .NET-based binaries from GitHub releases. Multi-arch aware (amd64/arm64).

set -euo pipefail

# Tool versions are passed in from the Docker build (ARG -> ENV) and
# originate in versions.json (the single source of truth). Failing fast
# here surfaces a missing wire-up in generate-bake.sh or the Dockerfile
# instead of silently baking a stale binary.
: "${GRYPE_VERSION:?GRYPE_VERSION must be set (passed from versions.json via Docker ARG)}"
: "${SYFT_VERSION:?SYFT_VERSION must be set (passed from versions.json via Docker ARG)}"
: "${OSV_SCANNER_VERSION:?OSV_SCANNER_VERSION must be set (passed from versions.json via Docker ARG)}"
: "${HADOLINT_VERSION:?HADOLINT_VERSION must be set (passed from versions.json via Docker ARG)}"
: "${GITLEAKS_VERSION:?GITLEAKS_VERSION must be set (passed from versions.json via Docker ARG)}"
: "${TRUFFLEHOG_VERSION:?TRUFFLEHOG_VERSION must be set (passed from versions.json via Docker ARG)}"
: "${DOCKLE_VERSION:?DOCKLE_VERSION must be set (passed from versions.json via Docker ARG)}"
: "${CYCLONEDX_CLI_VERSION:?CYCLONEDX_CLI_VERSION must be set (passed from versions.json via Docker ARG)}"

log() { printf '[install-scanner-tools] %s\n' "$*"; }

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
# SCA / SBOM tools (from quality-lite)
# ---------------------------------------------------------------------------

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
# Secret detection / container security tools (from security)
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

install_dockle() {
    log "installing dockle ${DOCKLE_VERSION} (${ARCH})"
    local arch_suffix="64bit"
    [[ "$ARCH" == "arm64" ]] && arch_suffix="ARM64"
    local url="https://github.com/goodwithtech/dockle/releases/download/v${DOCKLE_VERSION}/dockle_${DOCKLE_VERSION}_Linux-${arch_suffix}.tar.gz"
    curl -sSL "$url" | tar xz -C /usr/local/bin dockle
    chmod +x /usr/local/bin/dockle
    dockle --version
}

install_cyclonedx_cli() {
    # CycloneDX/cyclonedx-cli is a .NET self-contained binary. The Linux
    # releases ship glibc and musl variants for amd64, but no musl-arm64
    # exists upstream as of v0.31.0 (2026-04-29). On Alpine/musl arm64
    # we skip the install: lib/transverse/sbom.sh::sbom.merge falls back
    # to a pure-jq merge (proven by Phase 2 specs) when the binary is
    # absent.
    #
    # The musl-x64 variant is dynamically linked against libstdc++ and
    # libgcc_s (provided by Alpine's libstdc++ package), and expects ICU
    # for globalization. We avoid the 30 MB icu-libs dependency by
    # exporting DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 globally for the
    # binary (cyclonedx-cli only manipulates JSON, no locale-dependent
    # logic).
    local arch_suffix=""
    case "$ARCH" in
        amd64) arch_suffix="musl-x64" ;;
        arm64)
            log "cyclonedx-cli ${CYCLONEDX_CLI_VERSION} skipped (no musl-arm64 binary upstream); jq fallback in sbom.sh handles SBOM merge"
            return 0
            ;;
        *)
            log "cyclonedx-cli skipped (unsupported arch=${ARCH})"
            return 0
            ;;
    esac

    log "installing cyclonedx-cli ${CYCLONEDX_CLI_VERSION} (${ARCH}, ${arch_suffix})"
    apk add --no-cache libstdc++ >/dev/null
    local url="https://github.com/CycloneDX/cyclonedx-cli/releases/download/v${CYCLONEDX_CLI_VERSION}/cyclonedx-linux-${arch_suffix}"
    curl -sSL -o /usr/local/bin/cyclonedx-cli "$url"
    chmod +x /usr/local/bin/cyclonedx-cli
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 cyclonedx-cli --version
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    log "starting scanner tools installation"
    log "  ARCH=${ARCH}"

    install_grype
    install_syft
    install_osv_scanner
    install_hadolint
    install_gitleaks
    install_trufflehog
    install_dockle
    install_cyclonedx_cli

    log "all scanner tools installed successfully"
}

main "$@"
