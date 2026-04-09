#!/usr/bin/env bash
# install-quality-tools.sh - Install quality scanning tools into a Docker image.
#
# Installs: semgrep, osv-scanner, grype, syft, checkov, hadolint, license_finder, scancode
# Multi-arch aware (amd64/arm64).

set -euo pipefail

# Tool versions (pinned for reproducibility)
SEMGREP_VERSION="${SEMGREP_VERSION:-1.116.0}"
OSV_SCANNER_VERSION="${OSV_SCANNER_VERSION:-2.0.1}"
GRYPE_VERSION="${GRYPE_VERSION:-0.92.0}"
SYFT_VERSION="${SYFT_VERSION:-1.22.0}"
CHECKOV_VERSION="${CHECKOV_VERSION:-3.2.400}"
HADOLINT_VERSION="${HADOLINT_VERSION:-2.12.0}"
LICENSE_FINDER_VERSION="${LICENSE_FINDER_VERSION:-7.2.1}"
SCANCODE_VERSION="${SCANCODE_VERSION:-32.4.0}"

log() { printf '[install-quality-tools] %s\n' "$*"; }

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
# Python-based tools (semgrep, checkov, scancode)
# ---------------------------------------------------------------------------

install_python_tools() {
    log "installing semgrep ${SEMGREP_VERSION}, checkov ${CHECKOV_VERSION}, scancode ${SCANCODE_VERSION}"
    # Install separately to avoid opentelemetry version conflicts between semgrep and checkov
    pip install --no-cache-dir --break-system-packages \
        "semgrep==${SEMGREP_VERSION}"
    pip install --no-cache-dir --break-system-packages \
        "checkov==${CHECKOV_VERSION}"
    # scancode-toolkit depends on extractcode[full] which pulls native binary
    # packages (extractcode-7z, extractcode-libarchive, typecode-libmagic,
    # packagedcode-msitools) with no musl (Alpine) wheels.
    # Work around: create stub dist-info for unavailable native extras first,
    # then install scancode normally so pip resolves all transitive deps.
    _create_native_stubs
    pip install --no-cache-dir --break-system-packages \
        "scancode-toolkit==${SCANCODE_VERSION}"
    if [[ "$ARCH" == "amd64" ]]; then
        # On x86_64, attempt real native extraction helpers (best-effort)
        pip install --no-cache-dir --break-system-packages \
            "extractcode-7z>=16.5" "extractcode-libarchive>=16.5" \
            "typecode-libmagic>=40.0" 2>/dev/null || \
            log "native extractcode extras unavailable on musl/x86_64 - skipping"
    fi
}

# Create minimal dist-info stubs for native packages that have no musl wheels.
# This satisfies pip's dependency resolver so scancode-toolkit installs cleanly.
_create_native_stubs() {
    local site_packages
    site_packages="$(python3 -c 'import site; print(site.getsitepackages()[0])')"
    # Versions must satisfy extractcode[full] constraints (>=16.5.210525 etc.)
    local -A stub_versions=(
        [extractcode-7z]="16.5.999999"
        [extractcode-libarchive]="16.5.999999"
        [typecode-libmagic]="40.0.999999"
        [packagedcode-msitools]="0.0.999999"
    )
    local pkg
    for pkg in "${!stub_versions[@]}"; do
        # Skip if already genuinely installed
        pip show "$pkg" >/dev/null 2>&1 && continue
        local ver="${stub_versions[$pkg]}"
        local name="${pkg//-/_}"
        local dist_dir="${site_packages}/${name}-${ver}.dist-info"
        mkdir -p "$dist_dir"
        cat > "${dist_dir}/METADATA" <<METAEOF
Metadata-Version: 2.1
Name: ${pkg}
Version: ${ver}
Summary: Stub for Alpine/musl (no native wheel available)
METAEOF
        printf '' > "${dist_dir}/RECORD"
        printf 'pip\n' > "${dist_dir}/INSTALLER"
        log "created stub for ${pkg} (no musl wheel)"
    done
}

# ---------------------------------------------------------------------------
# Ruby-based tools (license_finder)
# ---------------------------------------------------------------------------

install_ruby_tools() {
    log "installing license_finder ${LICENSE_FINDER_VERSION}"
    gem install license_finder -v "${LICENSE_FINDER_VERSION}" --no-document
}

# ---------------------------------------------------------------------------
# Go binary tools (osv-scanner, grype, syft, hadolint)
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
    [[ "$ARCH" == "arm64" ]] && arch_suffix="arm64"
    local url="https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-${arch_suffix}"
    curl -sSL -o /usr/local/bin/hadolint "$url"
    chmod +x /usr/local/bin/hadolint
    hadolint --version
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    log "starting quality tools installation"
    log "  ARCH=${ARCH}"

    install_python_tools
    install_ruby_tools
    install_osv_scanner
    install_grype
    install_syft
    install_hadolint

    log "all quality tools installed successfully"
}

main "$@"
