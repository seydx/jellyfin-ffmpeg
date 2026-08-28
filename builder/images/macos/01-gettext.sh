#!/bin/bash
ffbuild_macbase() {
  # gnu.org and its mirrors drop out from the GitHub macOS runners now and
  # then (timeouts, 502s): several sources, bounded attempts, and a checksum
  # so every source is equally safe
  local sha256=ec1705b1e969b83a9f073144ec806151db88127f5e40fe5a94cb6c8fa48996a0
  local url
  for url in \
    https://ftpmirror.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz \
    https://mirrors.kernel.org/gnu/gettext/gettext-0.22.5.tar.gz \
    https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz; do
    if wget --timeout=30 --tries=2 "$url" -O gettext.tar.gz && echo "$sha256  gettext.tar.gz" | shasum -a 256 -c -; then
      break
    fi
    rm -f gettext.tar.gz
  done
  # the caller runs this function as `ffbuild_macbase || exit`, which disables
  # errexit inside it, so the download failure has to be returned explicitly
  test -s gettext.tar.gz || return 1
  tar xvf gettext.tar.gz
  cd gettext-0.22.5 || return 1
  ./configure --disable-silent-rules --disable-shared --enable-static --with-included-glib --with-included-libcroco --with-included-libunistring --with-included-libxml --with-emacs --with-lispdir="$FFBUILD_PREFIX"/share --disable-java --disable-csharp --without-git --without-cvs --without-xz --with-included-gettext --prefix="$FFBUILD_PREFIX"
  make -j$(nproc)
  make install
}
