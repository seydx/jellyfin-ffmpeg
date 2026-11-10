FROM ubuntu:resolute

ENV DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install --no-install-recommends \
        build-essential yasm nasm quilt \
        xxd pkgconf curl wget unzip zip git subversion mercurial rsync jq \
        autoconf automake libtool libtool-bin autopoint gettext cmake clang meson ninja-build \
        texinfo texi2html help2man flex bison groff \
        gperf itstool ragel libc6-dev zlib1g-dev libssl-dev \
        gtk-doc-tools gobject-introspection gawk \
        ocaml ocaml-findlib ocamlbuild libnum-ocaml-dev indent p7zip-full zstd \
        python3-setuptools python3-pip python3-venv python3-jinja2 python3-jsonschema \
        python3-apt python3-dev python-is-python3 && \
    apt-get -y clean && \
    git config --global user.email "builder@localhost" && \
    git config --global user.name "Builder" && \
    git config --global advice.detachedHead false

ENV CARGO_HOME="/opt/cargo" RUSTUP_HOME="/opt/rustup" PATH="/opt/cargo/bin:${PATH}" \
    CARGO_NET_RETRY=10 \
    CARGO_HTTP_MULTIPLEXING=false
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path
# crates.io occasionally drops HTTP/2 streams mid-download ("HTTP2 framing layer"),
# retry the whole install on top of the env vars above
RUN for i in 1 2 3 4 5; do cargo install --locked cargo-c && break || { echo "attempt $i failed; retrying in 10s..."; sleep 10; }; done \
 && rm -rf "${CARGO_HOME}"/registry "${CARGO_HOME}"/git

RUN --mount=src=.,dst=/input \
    for s in /input/*.sh; do cp $s /usr/bin/$(echo $s | sed -e 's|.*/||' -e 's/\.sh$//'); done
