<p align="center">
  <img src="docs/brik-images.jpg" alt="Brik">
</p>

<p align="center">
  <b>Brik, the portable pipeline standard.</b><br>
  <b>Write once. Run everywhere.</b>
</p>

[![Build](https://github.com/getbrik/brik-images/actions/workflows/build.yml/badge.svg)](https://github.com/getbrik/brik-images/actions/workflows/build.yml)

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

- Images are scanned with [Grype](https://github.com/anchore/grype) on every build (blocks on **critical** CVEs with available fixes)
- Scan results are uploaded to the [Security tab](https://github.com/getbrik/brik-images/security/code-scanning) for full visibility
- SBOMs are generated with [Syft](https://github.com/anchore/syft) in CycloneDX format
- Images are signed with [cosign](https://github.com/sigstore/cosign) (keyless, OIDC)
- Weekly rebuilds pick up base image security patches
- [Renovate](https://github.com/renovatebot/renovate) auto-merges digest updates

### Security policy

These images bundle the latest available versions of their respective base images and tools (yq, jq, git). Some upstream base images (e.g. `node:22-slim`, `python:3.13-slim`) may contain known vulnerabilities that have not yet been patched by their maintainers.

**What we control:** yq, jq, and git versions are pinned to the latest releases and updated regularly. The build fails on any **critical** CVE with an available fix.

**What we don't control:** CVEs in the upstream base images (Alpine, Debian, Ubuntu). These are resolved when the upstream maintainers publish updated images. Weekly rebuilds automatically pick up new patches.

Check the [Security tab](https://github.com/getbrik/brik-images/security/code-scanning) for the current scan results of every image.

### Suppressed CVEs (read this)

A small number of CVEs are intentionally suppressed in [`.grype.yaml`](.grype.yaml) so the build can stay green while we wait for upstream fixes. The full list is canonical in `.grype.yaml`; the table below explains the rationale at a glance:

| CVE | Affected binaries | Why suppressed | Removal criterion |
|-----|-------------------|----------------|-------------------|
| [CVE-2025-22871](https://nvd.nist.gov/vuln/detail/CVE-2025-22871) | `dockle` (statically linked go1.22.10) | Net/http request smuggling fixed in go1.23.8 / go1.24.2. The `dockle` upstream project appears unmaintained (last release 2025-01-06) and has not rebuilt against a patched Go. | `dockle` releases a new version compiled with go >= 1.23.8 |
| [CVE-2025-68121](https://nvd.nist.gov/vuln/detail/CVE-2025-68121) | `dockle` (go1.22.10), `gitleaks` (go1.24.11) | Go stdlib vulnerability fixed in go1.24.13. Latest `gitleaks` release (v8.30.1, 2026-03-12) was cut before that Go release; `dockle` is unmaintained. | `gitleaks` and `dockle` rebuild against go >= 1.24.13 |
| [CVE-2026-27143](https://nvd.nist.gov/vuln/detail/CVE-2026-27143) | `osv-scanner` (go1.26.1), `gitleaks` (go1.24.11), `dockle` (go1.22.10) | Compiler bug allowing memory corruption via integer overflow in induction-variable arithmetic. None of the three tools have a patched upstream release yet. `yq` was also affected on v4.52.5; we have already bumped `yq` to v4.53.2 which ships a patched Go. | All three tools rebuild against a patched Go release |

**Our reasoning.** Each suppression covers a CVE we cannot remediate from inside the image: the vulnerable binary is published statically by an upstream project on a pre-fix Go toolchain, and rebuilding from source with a patched Go would mean shipping a fork. We accept that exposure in exchange for keeping the scanner image available, with the trade-off documented per CVE so the next maintainer can audit it.

#### Automated weekly review

Every Monday at 02:30 UTC the [`CVE Suppression Review`](.github/workflows/cve-review.yml) workflow runs [`scripts/review-cve-suppressions.sh`](scripts/review-cve-suppressions.sh), compares each suppressed tool against its upstream GitHub release, and refreshes a sticky issue labelled [`cve-suppression-review`](https://github.com/getbrik/brik-images/issues?q=is%3Aopen+is%3Aissue+label%3Acve-suppression-review) with the result. The trade-off therefore stays visible on the repository dashboard and every BUMP_AVAILABLE row triggers an explicit follow-up. The structured metadata that drives the script lives in [`.cve-suppressions.json`](.cve-suppressions.json) -- treat it as the single source of truth for what needs to be reviewed.

You can run the same script locally on demand:

```bash
./scripts/review-cve-suppressions.sh
```

It requires `jq` and an authenticated `gh` CLI, and prints the same Markdown report to stdout.

#### Maintainer playbook

When the sticky issue refreshes:

1. **Open the issue** -- look for any row whose status is `BUMP_AVAILABLE`.
2. **Bump the tool** -- update the version in [`versions.json`](versions.json) (and the matching `ARG` default in any Dockerfile that pins it).
3. **Drop the suppression** -- if the next CI build no longer flags the CVE, remove the entry from both [`.grype.yaml`](.grype.yaml) AND [`.cve-suppressions.json`](.cve-suppressions.json), plus the row from the table above. Commit with `fix(scan): drop CVE-XXXX-YYYYY suppression now that <tool> ships go>=X.Y.Z`.

When you need to add a new suppression:

1. Prefer bumping the offending binary to a release that ships a patched compiler before suppressing anything.
2. If no patched upstream release exists, add the entry to **all three** of `.grype.yaml`, `.cve-suppressions.json`, and the table above. The script and workflow rely on the JSON metadata staying in lockstep with the YAML.
3. Each entry must record the affected binaries and the upstream runtime version (e.g. go1.24.11), plus a clear removal criterion.

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
- **yq** (v4.53.2) - YAML processor
- **jq** (1.8.1) - JSON processor
- **git** - version control
- **curl** - HTTP client

Stack images additionally include their respective toolchain (node/npm, python/pip, java/maven, etc.).

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
