#!/usr/bin/env bash
# smoke-test.sh - Run smoke tests on built Brik images.
#
# Usage:
#   ./scripts/smoke-test.sh                    # test all images from versions.json
#   ./scripts/smoke-test.sh node 22            # test a specific stack/version
#   ./scripts/smoke-test.sh --image <full-tag> # test a specific image tag

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSIONS_FILE="${ROOT_DIR}/versions.json"

PASS=0
FAIL=0
ERRORS=()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log_pass() { printf '  \033[32mPASS\033[0m %s\n' "$*"; PASS=$((PASS + 1)); }
log_fail() { printf '  \033[31mFAIL\033[0m %s\n' "$*"; FAIL=$((FAIL + 1)); ERRORS+=("$*"); }

smoke_test_image() {
    local image="$1"
    local verify_cmd="$2"

    printf '\nTesting %s\n' "$image"

    # Test 1: yq available
    if docker run --rm "$image" yq --version >/dev/null 2>&1; then
        log_pass "yq --version"
    else
        log_fail "${image}: yq --version"
    fi

    # Test 2: jq available
    if docker run --rm "$image" jq --version >/dev/null 2>&1; then
        log_pass "jq --version"
    else
        log_fail "${image}: jq --version"
    fi

    # Test 3: git available
    if docker run --rm "$image" git --version >/dev/null 2>&1; then
        log_pass "git --version"
    else
        log_fail "${image}: git --version"
    fi

    # Test 4: stack-specific verification
    if [[ -n "$verify_cmd" ]]; then
        if docker run --rm "$image" bash -c "$verify_cmd" >/dev/null 2>&1; then
            log_pass "verify: ${verify_cmd}"
        else
            log_fail "${image}: verify: ${verify_cmd}"
        fi
    fi
}

# ---------------------------------------------------------------------------
# Test a specific image by full tag
# ---------------------------------------------------------------------------

if [[ "${1:-}" == "--image" ]]; then
    image="${2:?Usage: smoke-test.sh --image <tag>}"
    verify_cmd="${3:-}"
    smoke_test_image "$image" "$verify_cmd"
    if [[ $FAIL -gt 0 ]]; then
        printf '\n\033[31m%d test(s) failed\033[0m\n' "$FAIL"
        exit 1
    fi
    printf '\n\033[32mAll %d tests passed\033[0m\n' "$PASS"
    exit 0
fi

# ---------------------------------------------------------------------------
# Test specific stack/version or all from matrix
# ---------------------------------------------------------------------------

REGISTRY="$(jq -r '.registry' "$VERSIONS_FILE")"

test_stack_version() {
    local stack="$1"
    local version="$2"
    local image_name="brik-runner-${stack}"
    local image="${REGISTRY}/${image_name}:${version}"
    local verify_cmd
    verify_cmd="$(jq -r ".stacks.\"${stack}\".verify_cmd" "$VERSIONS_FILE")"

    smoke_test_image "$image" "$verify_cmd"
}

if [[ $# -ge 2 ]]; then
    test_stack_version "$1" "$2"
else
    # Test all stacks and versions from the matrix
    for stack in $(jq -r '.stacks | keys[]' "$VERSIONS_FILE"); do
        for version in $(jq -r ".stacks.\"${stack}\".versions[]" "$VERSIONS_FILE"); do
            test_stack_version "$stack" "$version"
        done
    done
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "============================="
printf 'Passed: %d  Failed: %d\n' "$PASS" "$FAIL"
echo "============================="

if [[ $FAIL -gt 0 ]]; then
    echo ""
    echo "Failures:"
    for err in "${ERRORS[@]}"; do
        echo "  - $err"
    done
    exit 1
fi

exit 0
