# Security Policy

## Scope

This repository (`brik-images`) builds and publishes the official runner images consumed by the Brik CI/CD pipeline runtime. Images are published to `ghcr.io/getbrik/brik-runner-*`.

Each image is:

- Built reproducibly from a pinned base image (`alpine`, `node`, `python`, `eclipse-temurin`, `rust`, `mcr.microsoft.com/dotnet/sdk`, `debian`).
- Scanned with Grype at build time (Critical CVE with fix available fails the build).
- Signed with cosign (keyless OIDC via Sigstore).
- Attested with SLSA build provenance and a CycloneDX SBOM.
- Rebuilt weekly (Monday 03:00 UTC) to pick up upstream base image patches.

## Reporting a Vulnerability

If you discover a security vulnerability in a published image or in the build pipeline:

1. Go to https://github.com/getbrik/brik-images/security/advisories/new
2. Provide image name + tag + digest, the CVE or vulnerability identifier, and reproduction details.
3. We aim to acknowledge reports within 5 business days.

Do not open public issues for security reports.

## In Scope

- Build pipeline (`.github/workflows/build.yml`, `scheduled-rebuild.yml`, `cve-review.yml`).
- Dockerfiles under `images/*/`.
- Helper scripts under `scripts/`.
- The `versions.json` matrix and the `docker-bake.hcl` generator.

## Out of Scope

- CVEs in third-party tools embedded in the images (Grype, Syft, cosign, etc.). Report upstream.
- Suppressed CVEs documented in `.grype.yaml` (with a justification and an expiry date). These are reviewed weekly via `cve-review.yml` and tracked in the sticky issue labeled `cve-suppression-review`.
- CVEs in base images that are not yet fixed upstream. We pin the base, rebuild weekly, and accept a documented residual window.

## Verifying an Image

```bash
# Verify the cosign signature (Sigstore keyless)
cosign verify \
  --certificate-identity-regexp 'https://github.com/getbrik/brik-images/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  ghcr.io/getbrik/brik-runner-node:22

# Inspect the SLSA provenance
cosign verify-attestation \
  --type slsaprovenance \
  --certificate-identity-regexp 'https://github.com/getbrik/brik-images/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  ghcr.io/getbrik/brik-runner-node:22

# Inspect the SBOM
cosign download attestation --predicate-type 'https://cyclonedx.org/bom' \
  ghcr.io/getbrik/brik-runner-node:22 | jq -r '.payload' | base64 -d | jq .
```

## Disclosure Policy

Coordinated disclosure. Once a fixed image is published, we publish a GitHub Security Advisory (GHSA) listing affected tags and the fixed tag. Credit is given to the reporter unless they request otherwise.
