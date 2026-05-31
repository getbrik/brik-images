# brik-runner-stub -- workflow-adaptation test image (NOT a runtime image).
#
# Every external tool a stage might call (stack build/test, scanners, deploy,
# signing) is replaced by a no-op that exits 0. The real Brik runtime and the
# real CI shared libraries run unchanged on this image, so a pipeline exercises
# the FULL workflow -- context detection, the planner, the per-stage gates,
# needs/sequence -- WITHOUT doing any real (slow) work.
#
# Purpose: verify, fast and on the real orchestrator, that the pipeline adapts
# correctly to a project's initial conditions (git tag, passed variables,
# stack) and follows the expected run/skip workflow. A local proof on the
# `local` wrapper shows the full flow completes in ~6s with these stubs;
# brik tolerates empty tool output (findings -> 0 issues, no junit, no dist),
# so presence + exit 0 is enough for each stage to succeed and the DAG to flow.
#
# Do NOT use this image for real builds: it produces no artifacts.
ARG VERSION=3.23
FROM ghcr.io/getbrik/brik-runner-base:${VERSION}

# Brik prerequisites (yq, jq, git, jv) come from the base image and are left
# intact -- only the stack/scan/deploy/sign tools below are stubbed.
RUN set -eu; \
    for t in \
      node npm npx yarn pnpm corepack \
      python python3 pip pip3 poetry uv pipenv \
      cargo rustc rustup \
      java mvn gradle \
      dotnet \
      eslint prettier jest \
      semgrep grype gitleaks osv-scanner trivy syft cosign checkov bandit ruff dockle clippy \
      docker kubectl helm argocd rsync ssh scp ; do \
      printf '#!/bin/sh\nexit 0\n' > "/usr/local/bin/$t"; \
      chmod +x "/usr/local/bin/$t"; \
    done

RUN echo "brik-runner-stub" > /.brik-runner-stub
