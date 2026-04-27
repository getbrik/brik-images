# brik-runner-rust - Rust with Brik prerequisites
ARG VERSION=1
FROM rust:${VERSION}-slim-bookworm

ARG YQ_VERSION=v4.53.2
ARG JQ_VERSION=1.8.1

LABEL org.opencontainers.image.source="https://github.com/getbrik/brik-images"
LABEL org.opencontainers.image.title="brik-runner-rust"
LABEL org.opencontainers.image.description="Brik CI runner with Rust"
LABEL org.opencontainers.image.vendor="getbrik"
LABEL org.opencontainers.image.licenses="MIT"

ENV YQ_VERSION=${YQ_VERSION} \
    JQ_VERSION=${JQ_VERSION}

COPY scripts/install-brik-prereqs.sh /tmp/install-brik-prereqs.sh
RUN chmod +x /tmp/install-brik-prereqs.sh && /tmp/install-brik-prereqs.sh && rm /tmp/install-brik-prereqs.sh

# Mark as brik-runner image (detected by setup.sh to skip prerequisite install)
RUN echo "brik-runner" > /.brik-runner

# Install Rust components for quality checks (clippy, rustfmt) plus the
# llvm-tools-preview component (used by cargo-llvm-cov), and the chantier 15
# test-reporting helpers cargo-nextest (JUnit) and cargo-llvm-cov (lcov).
# cargo-binstall fetches prebuilt binaries from each project's GitHub
# release tarball, avoiding a multi-arch from-source compile that takes
# ~30 minutes under QEMU emulation. cargo-nextest also publishes a
# canonical install path at https://get.nexte.st but cargo-binstall keeps
# both helpers on the same install path.
RUN rustup component add clippy rustfmt llvm-tools-preview \
    && curl -L --proto '=https' --tlsv1.2 -sSf \
        https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh \
        | bash \
    && cargo binstall --no-confirm cargo-nextest cargo-llvm-cov \
    && yq --version && jq --version && rustc --version && cargo --version \
    && cargo nextest --version && cargo llvm-cov --version
