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

## Tag Convention

Each image is published with multiple tags:

```
ghcr.io/getbrik/brik-runner-node:22              # stack version
ghcr.io/getbrik/brik-runner-node:latest           # latest LTS
ghcr.io/getbrik/brik-runner-node:sha-a1b2c3d      # immutable git SHA
```

## What's Included

Every image contains:

- **bash** (5.x)
- **yq** (v4.52.5) - YAML processor
- **jq** (1.8.1) - JSON processor
- **git** - version control
- **curl** - HTTP client

Stack images additionally include their respective toolchain (node/npm, python/pip, java/maven, etc.).

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
  BRIK_CI_IMAGE: "ghcr.io/getbrik/brik-runner-node:22"

include:
  - project: 'brik/gitlab-templates'
    ref: v1
    file: '/templates/pipeline.yml'
```

Or override per-job:

```yaml
build:
  image: ghcr.io/getbrik/brik-runner-node:22
  script:
    - brik run stage build
```

### Jenkins

```groovy
pipeline {
    agent {
        docker {
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

```bash
# Generate the bake file from the version matrix
./scripts/generate-bake.sh

# Build all images (local only, no push)
docker buildx bake --load

# Build a single target
docker buildx bake --load node-22

# Run smoke tests
./scripts/smoke-test.sh
```

## Version Matrix

The build matrix is defined in `versions.json`. To add a new stack version:

1. Edit `versions.json`
2. Run `./scripts/generate-bake.sh`
3. Commit and push -- CI handles the rest

## License

MIT
