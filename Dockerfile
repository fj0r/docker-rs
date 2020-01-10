FROM nnurphy/deb

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup RUST_VERSION=1.40.0
ENV PATH=${CARGO_HOME}/bin:$PATH

RUN set -ex \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
    pkg-config libssl-dev lldb libxml2 \
    musl musl-dev musl-tools \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ARG wasmtime_url=https://github.com/bytecodealliance/wasmtime/releases/download/dev/wasmtime-dev-x86_64-linux.tar.xz
RUN set -ex \
  ; curl ${wasmtime_url} | tar Jxf - --strip-components=1 -C /usr/local/bin \
        wasmtime-dev-x86_64-linux/wasm2obj \
        wasmtime-dev-x86_64-linux/wasmtime \
  ; curl https://sh.rustup.rs -sSf \
    | sh -s -- --default-toolchain stable -y \
  ; rustup component add rls rust-analysis rust-src clippy rustfmt \
  ; rustup target add x86_64-unknown-linux-musl \
  # gluon_language-server mdbook
  ; cargo install cargo-wasi wasm-pack \
    ; cargo new hello-world \
    ; cd hello-world \
    ; cargo wasi run \
    ; popd \
    ; rm -rf hello-world \
  #; cargo install -q iron actix actix-web may reqwest \
  #  ; serde serde_yaml serde_json rlua clap nom handlebars \
  #  ; config chrono lru-cache itertools \
  ; rm -rf ${CARGO_HOME}/registry/src/*
