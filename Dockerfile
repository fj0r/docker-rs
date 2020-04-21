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
  ; rustup target add wasm32-wasi \
  ; cargo install cargo-wasi wasm-pack cargo-prefetch \
  ; cargo prefetch serde serde_yaml serde_json fern \
      reqwest actix actix-web diesel nom handlebars \
      structopt config chrono lru-cache itertools \
  ; rm -rf ${CARGO_HOME}/registry/src/*

RUN set -ex \
  ; export USER=root \
  ; cargo new hello-world \
  ; cd hello-world \
  ; cargo wasi build --release \
  ; cd .. \
  ; rm -rf hello-world
