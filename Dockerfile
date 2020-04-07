FROM nnurphy/deb

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup RUST_VERSION=1.42.0
ENV PATH=${CARGO_HOME}/bin:$PATH

RUN set -ex \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
    pkg-config libssl-dev lldb libxml2 \
    musl musl-dev musl-tools \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -ex \
  ; curl https://sh.rustup.rs -sSf \
    | sh -s -- --default-toolchain stable -y \
  ; rustup component add rust-analysis rust-src clippy rustfmt \
  ; rustup target add x86_64-unknown-linux-musl \
  # gluon_language-server mdbook
  ; cargo install cargo-wasi wasm-pack cargo-prefetch \
  ; cargo prefetch serde serde_yaml serde_json \
      structopt reqwest config chrono lru-cache itertools nom handlebars \
  #; cargo install -q iron actix actix-web may reqwest \
  #  ; serde serde_yaml serde_json rlua clap nom handlebars \
  #  ; config chrono lru-cache itertools \
  ; rm -rf ${CARGO_HOME}/registry/src/*

ENV wasmtime_version=v0.15.0
ARG wasmtime_url=https://github.com/bytecodealliance/wasmtime/releases/download/${wasmtime_version}/wasmtime-${wasmtime_version}-x86_64-linux.tar.xz
RUN set -ex \
  ; wget -O- ${wasmtime_url} | tar Jxf - --strip-components=1 -C /usr/local/bin \
        wasmtime-${wasmtime_version}-x86_64-linux/wasmtime \
  ; export USER=root \
  ; cargo new hello-world \
  ; cd hello-world \
  ; cargo wasi build --release \
  ; cd .. \
  ; rm -rf hello-world
