#!/usr/bin/env bash
# build-local.sh - Build Brik Docker images locally with docker buildx bake.
#
# Usage:
#   ./scripts/build-local.sh                       # build all images
#   ./scripts/build-local.sh node python            # build node and python stacks (all versions)
#   ./scripts/build-local.sh node-22 quality-1      # build specific targets
#   ./scripts/build-local.sh --list                 # list available targets
#
# Options:
#   --no-cache        Disable Docker build cache
#   --platform PLAT   Override platforms (e.g. "linux/amd64" for faster local builds)
#   --load            Load single-platform images into local Docker (implies --platform with native arch)
#   --push            Push images to registry (requires authentication)
#   --list            List available bake targets and exit
#   --dry-run         Show the docker buildx bake command without executing it
#   --regenerate      Regenerate docker-bake.hcl before building

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSIONS_FILE="${ROOT_DIR}/versions.json"
BAKE_FILE="${ROOT_DIR}/docker-bake.hcl"

# Defaults
NO_CACHE=""
PLATFORM=""
LOAD=""
PUSH=""
DRY_RUN=""
REGENERATE=""
TARGETS=()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

usage() {
    sed -n '2,/^$/{ s/^# //; s/^#$//; p }' "$0"
    exit 0
}

die() { printf '\033[31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

detect_native_platform() {
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64)  echo "linux/amd64" ;;
        arm64|aarch64) echo "linux/arm64" ;;
        *) echo "linux/${arch}" ;;
    esac
}

# Resolve stack names (e.g. "node") to bake targets (e.g. "node-22 node-24")
resolve_target() {
    local name="$1"
    # If the name matches an existing bake target exactly, use it
    if grep -q "^target \"${name}\"" "$BAKE_FILE" 2>/dev/null; then
        echo "$name"
        return
    fi
    # Otherwise treat it as a stack name and expand all its versions
    if jq -e ".stacks.\"${name}\"" "$VERSIONS_FILE" >/dev/null 2>&1; then
        local targets=()
        for version in $(jq -r ".stacks.\"${name}\".versions[]" "$VERSIONS_FILE"); do
            local target_name="${name}-$(echo "$version" | tr '.' '-')"
            targets+=("$target_name")
        done
        echo "${targets[*]}"
        return
    fi
    die "unknown target or stack: ${name}"
}

list_targets() {
    if [[ ! -f "$BAKE_FILE" ]]; then
        die "docker-bake.hcl not found. Run ./scripts/generate-bake.sh first."
    fi
    echo "Available bake targets:"
    echo ""
    printf '  %-20s %s\n' "TARGET" "TAGS"
    printf '  %-20s %s\n' "------" "----"
    grep -E '^target ' "$BAKE_FILE" | sed 's/target "\(.*\)" {/\1/' | while read -r target; do
        tags=$(sed -n "/^target \"${target}\"/,/^}/{ /tags/{ s/.*tags = \[//; s/\]//; s/\"//g; s/,/ /g; p; }; }" "$BAKE_FILE" | xargs)
        printf '  %-20s %s\n' "$target" "$tags"
    done
    echo ""
    echo "Stacks (expand to all versions):"
    echo ""
    for stack in $(jq -r '.stacks | keys[]' "$VERSIONS_FILE"); do
        versions=$(jq -r ".stacks.\"${stack}\".versions | join(\", \")" "$VERSIONS_FILE")
        printf '  %-20s versions: %s\n' "$stack" "$versions"
    done
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)     usage ;;
        --no-cache)    NO_CACHE="1"; shift ;;
        --platform)    PLATFORM="${2:?--platform requires a value}"; shift 2 ;;
        --load)        LOAD="1"; shift ;;
        --push)        PUSH="1"; shift ;;
        --list)        list_targets; exit 0 ;;
        --dry-run)     DRY_RUN="1"; shift ;;
        --regenerate)  REGENERATE="1"; shift ;;
        -*)            die "unknown option: $1" ;;
        *)             TARGETS+=("$1"); shift ;;
    esac
done

# ---------------------------------------------------------------------------
# Prechecks
# ---------------------------------------------------------------------------

command -v docker >/dev/null 2>&1 || die "docker is required"
command -v jq >/dev/null 2>&1    || die "jq is required"

# --load requires single platform
if [[ -n "$LOAD" && -z "$PLATFORM" ]]; then
    PLATFORM="$(detect_native_platform)"
fi

# --load and --push are mutually exclusive
if [[ -n "$LOAD" && -n "$PUSH" ]]; then
    die "--load and --push are mutually exclusive"
fi

# Regenerate bake file if requested
if [[ -n "$REGENERATE" ]]; then
    echo "Regenerating docker-bake.hcl..."
    bash "${SCRIPT_DIR}/generate-bake.sh"
fi

if [[ ! -f "$BAKE_FILE" ]]; then
    die "docker-bake.hcl not found. Run ./scripts/generate-bake.sh or use --regenerate."
fi

# ---------------------------------------------------------------------------
# Resolve targets
# ---------------------------------------------------------------------------

RESOLVED_TARGETS=()
if [[ ${#TARGETS[@]} -eq 0 ]]; then
    # No targets specified -- build all (default group)
    RESOLVED_TARGETS=()
else
    for t in "${TARGETS[@]}"; do
        for resolved in $(resolve_target "$t"); do
            RESOLVED_TARGETS+=("$resolved")
        done
    done
fi

# ---------------------------------------------------------------------------
# Build the docker buildx bake command
# ---------------------------------------------------------------------------

CMD=(docker buildx bake)
CMD+=(-f "$BAKE_FILE")

if [[ -n "$NO_CACHE" ]]; then
    CMD+=(--no-cache)
fi

if [[ -n "$PLATFORM" ]]; then
    CMD+=(--set "*.platform=${PLATFORM}")
fi

if [[ -n "$LOAD" ]]; then
    CMD+=(--load)
fi

if [[ -n "$PUSH" ]]; then
    CMD+=(--push)
fi

# Add resolved targets (empty = default group = all)
CMD+=("${RESOLVED_TARGETS[@]}")

# ---------------------------------------------------------------------------
# Execute
# ---------------------------------------------------------------------------

echo "Building images..."
if [[ ${#RESOLVED_TARGETS[@]} -eq 0 ]]; then
    echo "  Targets: all (default group)"
else
    echo "  Targets: ${RESOLVED_TARGETS[*]}"
fi
if [[ -n "$PLATFORM" ]]; then
    echo "  Platform: ${PLATFORM}"
fi
echo ""
echo "  ${CMD[*]}"
echo ""

if [[ -n "$DRY_RUN" ]]; then
    echo "(dry-run -- command not executed)"
    exit 0
fi

exec "${CMD[@]}"
