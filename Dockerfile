FROM nnurphy/deb

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup RUST_VERSION=1.39.0
ENV PATH=${CARGO_HOME}/bin:$PATH

RUN set -ex \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
    pkg-config libssl-dev lldb libxml2 \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -ex \
  ; curl https://sh.rustup.rs -sSf \
    | sh -s -- --default-toolchain stable -y \
  ; rustup component add rls rust-analysis rust-src clippy rustfmt \
  # gluon_language-server mdbook
  ; cargo install wasm-pack \
  #; cargo install -q iron actix actix-web may reqwest \
  #  ; serde serde_yaml serde_json rlua clap nom handlebars \
  #  ; config chrono lru-cache itertools \
  ; rm -rf ${CARGO_HOME}/registry/src/*
