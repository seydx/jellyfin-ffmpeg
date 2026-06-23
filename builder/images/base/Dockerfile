FROM ubuntu:noble

ENV DEBIAN_FRONTEND=noninteractive

# Use more reliable mirrors for Ubuntu packages
RUN mkdir -p /etc/apt/sources.list.d/ \
 && touch /etc/apt/sources.list /etc/apt/sources.list.d/ubuntu.sources \
 && sed -i 's|archive.ubuntu.com/ubuntu/|mirrors.kernel.org/ubuntu/|g' \
    /etc/apt/sources.list /etc/apt/sources.list.d/ubuntu.sources \
 && sed -i 's|security.ubuntu.com/ubuntu/|mirrors.kernel.org/ubuntu/|g' \
    /etc/apt/sources.list /etc/apt/sources.list.d/ubuntu.sources

RUN \
    apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install build-essential yasm nasm quilt rsync \
        xxd pkgconf curl wget unzip git subversion mercurial \
        autoconf automake libtool libtool-bin autopoint gettext cmake clang meson ninja-build \
        texinfo texi2html help2man flex bison groff \
        gperf itstool ragel libc6-dev zlib1g-dev libssl-dev \
        gtk-doc-tools gobject-introspection gawk \
        ocaml ocamlbuild libnum-ocaml-dev indent p7zip-full \
        python3-setuptools python3-jinja2 python3-apt python-is-python3 && \
    apt-get -y clean && \
    git config --global user.email "builder@localhost" && \
    git config --global user.name "Builder" && \
    git config --global advice.detachedHead false

ENV CARGO_HOME="/opt/cargo" RUSTUP_HOME="/opt/rustup" PATH="/opt/cargo/bin:${PATH}" \
    CARGO_NET_RETRY=10 \
    CARGO_HTTP_MULTIPLEXING=false
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path
# Retry loop: crates.io occasionally drops HTTP2 streams mid-download
# ("HTTP2 framing layer" errors). Combined with the env vars above this
# makes the install resilient to transient network flakes.
RUN for i in 1 2 3 4 5; do cargo install --locked cargo-c && break || { echo "attempt $i failed; retrying in 10s..."; sleep 10; }; done \
 && rm -rf "${CARGO_HOME}"/registry "${CARGO_HOME}"/git

RUN --mount=src=.,dst=/input \
    for s in /input/*.sh; do cp $s /usr/bin/$(echo $s | sed -e 's|.*/||' -e 's/\.sh$//'); done
