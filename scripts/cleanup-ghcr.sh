#!/usr/bin/env bash
# cleanup-ghcr.sh -- prune obsolete GHCR container package versions.
#
# Replaces dataaxiom/ghcr-cleanup-action, which fatally errors on the 404 a
# DELETE returns when its target was already removed by a manifest cascade.
# Here a 404 on DELETE means "already gone" and is counted as a success.
#
# Per package, the KEEP set is:
#   - every version carrying `latest` or a stack version tag (current images);
#   - the KEEP_N_SHA most recent `sha-<commit>` tagged versions;
#   - every `sha256-*` tagged version (cosign signatures -- kept wholesale,
#     they are tiny and mapping each back to its image is not worth the cost);
#   - the platform children of every kept image manifest list;
#   - the referrers (SLSA attestations, ...) of every kept image.
# Everything else -- untagged orphans, stale sha-<commit> images and their
# now-unreferenced children -- is deleted.
#
# Environment:
#   GH_TOKEN    GitHub token with packages:write on the org   (required)
#   PACKAGES    comma-separated container package names        (required)
#   ORG         organisation                                  (default getbrik)
#   KEEP_N_SHA  sha-<commit> tags to keep, newest first        (default 20)
#   DRY_RUN     "true" => log the plan, delete nothing         (default false)

set -euo pipefail

ORG="${ORG:-getbrik}"
KEEP_N_SHA="${KEEP_N_SHA:-20}"
DRY_RUN="${DRY_RUN:-false}"
: "${PACKAGES:?PACKAGES must be set}"
: "${GH_TOKEN:?GH_TOKEN must be set}"

log() { printf '%s\n' "$*"; }

# Anonymous pull token for a public GHCR repo (manifest + referrer reads).
registry_token() {
  curl -fsSL "https://ghcr.io/token?scope=repository:${ORG}/${1}:pull" \
    | jq -r '.token'
}

# Digests reachable from a manifest: platform children of an index plus any
# referrers (attestations, signatures). Empty for a plain single-arch image.
referenced_digests() {
  local repo="$1" digest="$2" tok="$3" accept
  accept='application/vnd.oci.image.index.v1+json'
  accept="${accept},application/vnd.docker.distribution.manifest.list.v2+json"
  curl -fsSL -H "Authorization: Bearer ${tok}" -H "Accept: ${accept}" \
    "https://ghcr.io/v2/${ORG}/${repo}/manifests/${digest}" 2>/dev/null \
    | jq -r '.manifests[]?.digest // empty' 2>/dev/null || true
  curl -fsSL -H "Authorization: Bearer ${tok}" \
    -H 'Accept: application/vnd.oci.image.index.v1+json' \
    "https://ghcr.io/v2/${ORG}/${repo}/referrers/${digest}" 2>/dev/null \
    | jq -r '.manifests[]?.digest // empty' 2>/dev/null || true
}

grand_deleted=0 grand_cascade=0 had_error=0
IFS=',' read -ra pkg_list <<<"$PACKAGES"

for pkg in "${pkg_list[@]}"; do
  [[ -z "$pkg" ]] && continue
  log "::group::${pkg}"
  tok="$(registry_token "$pkg")"

  # One TSV line per version: id <TAB> digest <TAB> created <TAB> tags(csv).
  versions="$(gh api "orgs/${ORG}/packages/container/${pkg}/versions?per_page=100" \
      --paginate \
      --jq '.[] | [.id, .name, .created_at,
                   (.metadata.container.tags // [] | join(","))] | @tsv')"

  # --- classify versions by tag -----------------------------------------
  img_digests=""   # version-tagged image digests (latest / 22 / 3.23 / ...)
  sha_lines=""     # "created<TAB>digest" for sha-<commit> tagged versions
  sig_digests=""   # sha256-* tagged versions (cosign signatures)
  while IFS=$'\t' read -r id digest created tags; do
    [[ -z "$id" ]] && continue
    IFS=',' read -ra tarr <<<"$tags"
    for t in "${tarr[@]}"; do
      case "$t" in
        sha-*)    sha_lines+="${created}"$'\t'"${digest}"$'\n' ;;
        sha256-*) sig_digests+="${digest}"$'\n' ;;
        ?*)       img_digests+="${digest}"$'\n' ;;
      esac
    done
  done <<<"$versions"

  # Seeds to expand = current images + the KEEP_N_SHA newest sha-<commit>.
  expand_seeds="$img_digests"
  if [[ -n "$sha_lines" ]]; then
    expand_seeds+="$(printf '%s' "$sha_lines" \
                       | sort -ru | head -n "$KEEP_N_SHA" | cut -f2)"$'\n'
  fi
  expand_seeds="$(printf '%s' "$expand_seeds" | sort -u | grep -v '^$' || true)"

  # KEEP = seeds + signatures + children/referrers of every seed.
  keep="${expand_seeds}"$'\n'"${sig_digests}"
  while IFS= read -r d; do
    [[ -z "$d" ]] && continue
    while IFS= read -r ref; do
      [[ -n "$ref" ]] && keep+="${ref}"$'\n'
    done <<<"$(referenced_digests "$pkg" "$d" "$tok")"
  done <<<"$expand_seeds"
  keep="$(printf '%s' "$keep" | sort -u | grep -v '^$' || true)"

  # --- delete every version whose digest is not in KEEP ------------------
  pkg_deleted=0
  while IFS=$'\t' read -r id digest created tags; do
    [[ -z "$id" ]] && continue
    grep -qxF "$digest" <<<"$keep" && continue
    if [[ "$DRY_RUN" == "true" ]]; then
      log "  would delete  ${id}  ${digest}  [${tags}]"
      pkg_deleted=$((pkg_deleted + 1))
      continue
    fi
    if err="$(gh api --method DELETE \
                "orgs/${ORG}/packages/container/${pkg}/versions/${id}" \
                2>&1 >/dev/null)"; then
      pkg_deleted=$((pkg_deleted + 1))
    elif grep -q 'HTTP 404' <<<"$err"; then
      # Already removed by a cascade -- the desired end state.
      pkg_deleted=$((pkg_deleted + 1))
      grand_cascade=$((grand_cascade + 1))
    else
      log "::warning::${pkg} version ${id}: ${err}"
      had_error=1
    fi
  done <<<"$versions"

  kept_count="$(grep -c . <<<"$keep" || true)"
  verb="deleted"; [[ "$DRY_RUN" == "true" ]] && verb="would delete"
  log "  ${pkg}: kept ${kept_count} digests, ${verb} ${pkg_deleted}"
  log "::endgroup::"
  grand_deleted=$((grand_deleted + pkg_deleted))
done

verb="Deleted"; [[ "$DRY_RUN" == "true" ]] && verb="Would delete"
log ""
log "${verb} ${grand_deleted} versions total (${grand_cascade} already gone via cascade)."
[[ $had_error -eq 0 ]] || {
  log "::error::one or more deletions failed with a non-404 error"
  exit 1
}
