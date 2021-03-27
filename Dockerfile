FROM nnurphy/io

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup
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
  ; rustup component add rust-src clippy rustfmt \
  ; rustup target add x86_64-unknown-linux-musl \
  ; rustup target add wasm32-wasi \
  ; cargo install cargo-wasi wasm-pack cargo-prefetch \
      systemfd cargo-watch cargo-edit cargo-feature \
  ; cargo prefetch \
      quicli structopt \
      actix actix-web \
      thiserror anyhow \
      serde serde_derive serde_yaml serde_json \
      slog slog-async slog-json slog-term \
      reqwest oxidizer nom handlebars \
      config chrono lru-cache itertools \
  ; rm -rf ${CARGO_HOME}/registry/src/*

RUN set -ex \
  ; mkdir -p /opt/language-server/rust \
  ; curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux \
        -o /opt/language-server/rust/rust-analyzer \
  ; chmod +x /opt/language-server/rust/rust-analyzer \
  ; ln -fs /opt/language-server/rust/rust-analyzer /usr/local/bin

RUN set -eux \
  ; nvim_home=/etc/skel/.config/nvim \
  ; $nvim_home/plugged/vimspector/install_gadget.py --enable-rust \
  ; rm -f $nvim_home/plugged/vimspector/gadgets/linux/download/*/*/*.vsix

RUN set -ex \
  ; export USER=root \
  ; cargo new hello-world \
  ; cd hello-world \
  ; cargo wasi build --release \
  ; cd .. \
  ; rm -rf hello-world
