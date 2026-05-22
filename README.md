<p align="center">
  <img src="docs/brik-images.jpg" alt="Brik">
</p>

<p align="center">
  <b>Brik, the portable pipeline standard.</b><br>
  <b>Write once. Run everywhere.</b>
</p>

[![Build](https://github.com/getbrik/brik-images/actions/workflows/build.yml/badge.svg)](https://github.com/getbrik/brik-images/actions/workflows/build.yml)
[![Build provenance](https://img.shields.io/badge/build%20provenance-attested-brightgreen?logo=github)](https://github.com/getbrik/brik-images/attestations)
[![Signed with cosign](https://img.shields.io/badge/cosign-signed-blue?logo=sigstore)](#verifying)

Official Docker images for [Brik](https://github.com/getbrik/brik) CI/CD runners.

Pre-built images with all Brik prerequisites (bash 5+, yq, jq, git) and stack-specific tools. Eliminates the ~30-40s bootstrap overhead from every CI job.

## Available Images

| Image | Version | Security | Pull command |
|-------|---------|----------|--------------|
| `brik-runner-base` | `3.23` | ![CVEs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/getbrik/brik-images/main/docs/badges/base-3.23.json) | `docker pull ghcr.io/getbrik/brik-runner-base` |
| `brik-runner-node` | `22` | ![CVEs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/getbrik/brik-images/main/docs/badges/node-22.json) | `docker pull ghcr.io/getbrik/brik-runner-node:22` |
| `brik-runner-node` | `24` | ![CVEs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/getbrik/brik-images/main/docs/badges/node-24.json) | `docker pull ghcr.io/getbrik/brik-runner-node:24` |
| `brik-runner-python` | `3.13` | ![CVEs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/getbrik/brik-images/main/docs/badges/python-3.13.json) | `docker pull ghcr.io/getbrik/brik-runner-python:3.13` |
| `brik-runner-python` | `3.14` | ![CVEs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/getbrik/brik-images/main/docs/badges/python-3.14.json) | `docker pull ghcr.io/getbrik/brik-runner-python:3.14` |
| `brik-runner-java` | `21` | ![CVEs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/getbrik/brik-images/main/docs/badges/java-21.json) | `docker pull ghcr.io/getbrik/brik-runner-java:21` |
| `brik-runner-java` | `25` | ![CVEs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/getbrik/brik-images/main/docs/badges/java-25.json) | `docker pull ghcr.io/getbrik/brik-runner-java:25` |
| `brik-runner-rust` | `1` | ![CVEs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/getbrik/brik-images/main/docs/badges/rust-1.json) | `docker pull ghcr.io/getbrik/brik-runner-rust:1` |
| `brik-runner-dotnet` | `9.0` | ![CVEs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/getbrik/brik-images/main/docs/badges/dotnet-9.0.json) | `docker pull ghcr.io/getbrik/brik-runner-dotnet:9.0` |
| `brik-runner-dotnet` | `10.0` | ![CVEs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/getbrik/brik-images/main/docs/badges/dotnet-10.0.json) | `docker pull ghcr.io/getbrik/brik-runner-dotnet:10.0` |
| `brik-runner-analysis` | `1` | ![CVEs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/getbrik/brik-images/main/docs/badges/analysis-1.json) | `docker pull ghcr.io/getbrik/brik-runner-analysis` |
| `brik-runner-scanner` | `1` | ![CVEs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/getbrik/brik-images/main/docs/badges/scanner-1.json) | `docker pull ghcr.io/getbrik/brik-runner-scanner` |

All images are multi-arch: `linux/amd64` and `linux/arm64`.

## Security

Every image is scanned, signed, and continuously rebuilt:

- Scanned with [Grype](https://github.com/anchore/grype) on every build. The build **hard-fails only on a Critical CVE that has an available upstream fix** -- Critical and High CVEs that upstream has not patched yet are recorded, not blocked.
- Scan results are uploaded to the [Security tab](https://github.com/getbrik/brik-images/security/code-scanning) for full per-image visibility.
- SBOMs are generated with [Syft](https://github.com/anchore/syft) in CycloneDX format.
- Images are signed with [cosign](https://github.com/sigstore/cosign) (keyless, OIDC).
- Every build applies the base image's pending OS security updates (`apt-get upgrade`); weekly rebuilds also refresh the base images, and [Renovate](https://github.com/renovatebot/renovate) auto-merges digest updates.

### Verifying

Every image is signed with cosign (keyless) and carries a SLSA build-provenance attestation. To verify a pulled image yourself (adjust the tag as needed):

```bash
# cosign signature
cosign verify ghcr.io/getbrik/brik-runner-node:24 \
  --certificate-identity-regexp 'https://github.com/getbrik/brik-images/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com

# GitHub build-provenance attestation
gh attestation verify oci://ghcr.io/getbrik/brik-runner-node:24 --owner getbrik
```

Every attestation is also listed on the [Attestations page](https://github.com/getbrik/brik-images/attestations).

### Current CVE posture

**These images are not CVE-free.** They bundle the latest upstream base images (`node:*-slim`, `python:*-slim`, Debian, Alpine, ...), and those carry vulnerabilities their maintainers have not patched yet. Several stack images currently show **Critical** CVEs, and every non-base image shows dozens of **High** -- the per-image badge in the [Available Images](#available-images) table is the live count, and the [Security tab](https://github.com/getbrik/brik-images/security/code-scanning) the per-CVE detail. Treat those, not this prose, as the source of truth.

**What we control:** the bundled tools (`yq`, `jq`, `git`, and the scanner/analysis binaries) are pinned to current releases and bumped regularly; the build blocks on a Critical that has a fix.

**What we don't control:** CVEs in the language runtimes themselves and in statically-linked Go binaries -- those clear only when the runtime or tool upstream ships a patched release. For production use, pin images by digest and run a scan gate against your own risk policy.

### Suppressed CVEs (read this)

A few CVEs are suppressed in [`.grype.yaml`](.grype.yaml) so the build can stay green: Go-toolchain vulnerabilities compiled into statically-linked scanner binaries (`dockle`, `gitleaks`, `osv-scanner`) that we cannot remediate without forking the upstream project. [`.grype.yaml`](.grype.yaml) is the canonical list.

The **live status** -- the per-tool breakdown, and whether a patched upstream release is available yet -- is the auto-refreshed [CVE Suppression Review issue](https://github.com/getbrik/brik-images/issues?q=is%3Aissue+label%3Acve-suppression-review), regenerated every Monday by [`scripts/review-cve-suppressions.sh`](scripts/review-cve-suppressions.sh). When a tool ships a release on a patched Go, bump it in [`versions.json`](versions.json) and drop its entry from `.grype.yaml` and [`.cve-suppressions.json`](.cve-suppressions.json).

## Tag Convention

Each image is published with multiple tags:

```
ghcr.io/getbrik/brik-runner-node:22              # stack version (mutable)
ghcr.io/getbrik/brik-runner-node:latest           # latest LTS (mutable)
ghcr.io/getbrik/brik-runner-node:sha-a1b2c3d      # immutable git SHA
ghcr.io/getbrik/brik-runner-node:22@sha256:...    # digest pin (most secure)
```

**For production pipelines**, pin images by digest (`@sha256:...`) to guarantee reproducible builds. Mutable tags like `:22` or `:latest` can change on rebuilds. Use `docker inspect --format='{{index .RepoDigests 0}}' <image>` to retrieve the current digest.

## What's Included

Every image contains:

- **bash** (5.x)
- **yq** - YAML processor
- **jq** - JSON processor
- **git** - version control
- **curl** - HTTP client

Stack images additionally include their respective toolchain (node/npm, python/pip, java/maven, etc.). Exact pinned versions of every bundled tool are in [`versions.json`](versions.json).

### Analysis vs Scanner

The scanning tooling is split into two images based on their runtime requirements:

- **analysis** -- Python/Ruby runtime, for deep SAST analysis, license compliance, and IaC scanning (semgrep, checkov, scancode, license_finder)
- **scanner** -- static Go binaries only, fast to pull, for vulnerability scanning, secret detection, Dockerfile linting, and container scanning

### Analysis Image

The `brik-runner-analysis` image (~1.7 GB) bundles Python/Ruby-based analysis tools via multi-stage build:

| Tool | Purpose |
|------|---------|
| semgrep | Static analysis (SAST) |
| checkov | Infrastructure-as-Code scanning |
| scancode-toolkit | License and origin detection |
| license_finder | License compliance |

### Scanner Image

The `brik-runner-scanner` image (~500 MB) bundles static Go binary tools -- no Python or Ruby runtime:

| Tool | Purpose |
|------|---------|
| grype | Vulnerability scanning (SCA) |
| syft | SBOM generation |
| osv-scanner | Open-source vulnerability scanning |
| hadolint | Dockerfile linting |
| gitleaks | Secret/credential leak detection |
| trufflehog | Secret scanning (entropy + patterns) |
| dockle | Docker image best-practice linting |

Pinned versions for all tools are in [`versions.json`](versions.json).

**Note:** The brik runtime is NOT pre-installed. It is cloned at CI time by the shared library's `before_script`. This decouples image releases from brik releases.

## Roadmap: Brik Runtime in Images

Currently, the brik runtime is cloned at CI time by the shared library's `before_script`. This keeps image releases decoupled from brik development, which is the right trade-off during active development.

Once brik reaches a stable release cadence, the runtime will be pre-installed in the images. This will unlock:

- **Zero-config local usage** -- `docker run ghcr.io/getbrik/brik-runner-node:22 brik run stage build` with no setup, no clone, no CI platform required.
- **Fully offline pipelines** -- images become self-contained, no network dependency at runtime.
- **Freemium / Enterprise tiers** -- community images ship with brik core; enterprise images could include additional modules, caching layers, or premium integrations.

## Usage

### GitLab CI

```yaml
# .gitlab-ci.yml
variables:
  # Pin by digest for reproducible builds: ghcr.io/getbrik/brik-runner-node:22@sha256:...
  BRIK_CI_IMAGE: "ghcr.io/getbrik/brik-runner-node:22"

include:
  - project: 'brik/gitlab-templates'
    ref: v1
    file: '/templates/pipeline.yml'
```

Or override per-job:

```yaml
build:
  image: ghcr.io/getbrik/brik-runner-node:22  # or :22@sha256:... for digest pin
  script:
    - brik run stage build
```

### Jenkins

```groovy
pipeline {
    agent {
        docker {
            // Pin by digest for reproducible builds:
            // image 'ghcr.io/getbrik/brik-runner-java:21@sha256:...'
            image 'ghcr.io/getbrik/brik-runner-java:21'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh 'brik run stage build'
            }
        }
    }
}
```

### GitHub Actions

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      # Pin by digest for reproducible builds:
      # image: ghcr.io/getbrik/brik-runner-node:22@sha256:...
      image: ghcr.io/getbrik/brik-runner-node:22
    steps:
      - uses: actions/checkout@v4
      - run: brik run stage build
```

### Local Development

```bash
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  ghcr.io/getbrik/brik-runner-node:22 \
  brik run stage build
```

## Building Locally

### Quick Start

```bash
# Build all images (multi-arch, no push)
./scripts/build-local.sh

# Build and load into local Docker (native arch only)
./scripts/build-local.sh --load

# Build specific stacks (expands to all versions)
./scripts/build-local.sh --load node python

# Build specific targets
./scripts/build-local.sh --load analysis-1 scanner-1
```

### build-local.sh Options

| Option | Description |
|--------|-------------|
| (no args) | Build all images (multi-arch) |
| `<stack>` | Build all versions of a stack (e.g. `node` builds `node-22` + `node-24`) |
| `<target>` | Build a specific target (e.g. `node-22`, `quality-1`) |
| `--load` | Load images into local Docker (forces native arch) |
| `--platform PLAT` | Override platforms (e.g. `linux/amd64`) |
| `--no-cache` | Disable Docker build cache |
| `--regenerate` | Regenerate `docker-bake.hcl` before building |
| `--push` | Push images to registry (requires authentication) |
| `--list` | List all available targets and stacks |
| `--dry-run` | Show the command without executing it |

### Examples

```bash
# List available targets
./scripts/build-local.sh --list

# Rebuild analysis image from scratch, single arch
./scripts/build-local.sh --load --no-cache analysis-1

# Build for a specific platform
./scripts/build-local.sh --platform linux/amd64 scanner-1

# Regenerate bake file and build everything
./scripts/build-local.sh --regenerate --load

# Preview the command without running it
./scripts/build-local.sh --dry-run node java
```

### Other Scripts

```bash
# Generate the bake file from the version matrix
./scripts/generate-bake.sh

# Run smoke tests on built images
./scripts/smoke-test.sh

# Lint Dockerfiles
hadolint images/*/Dockerfile
```

## Version Matrix

All tool and stack versions are defined in `versions.json` (single source of truth). To add or update a version:

1. Edit `versions.json`
2. Run `./scripts/generate-bake.sh` (or use `--regenerate` with `build-local.sh`)
3. Commit and push -- CI handles the rest

## License

MIT
