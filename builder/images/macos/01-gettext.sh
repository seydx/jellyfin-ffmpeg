#!/bin/bash
ffbuild_macbase() {
  # ftp.gnu.org times out from the GitHub macOS runners now and then; the
  # mirror redirector comes first and every attempt is bounded so a dead host
  # fails within a minute instead of wget's 20 tries
  local url
  for url in \
    https://ftpmirror.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz \
    https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz \
    https://mirrors.kernel.org/gnu/gettext/gettext-0.22.5.tar.gz; do
    if wget --timeout=30 --tries=2 "$url" -O gettext.tar.gz; then
      break
    fi
    rm -f gettext.tar.gz
  done
  test -s gettext.tar.gz
  tar xvf gettext.tar.gz
  cd gettext-0.22.5
  ./configure --disable-silent-rules --disable-shared --enable-static --with-included-glib --with-included-libcroco --with-included-libunistring --with-included-libxml --with-emacs --with-lispdir="$FFBUILD_PREFIX"/share --disable-java --disable-csharp --without-git --without-cvs --without-xz --with-included-gettext --prefix="$FFBUILD_PREFIX"
  make -j$(nproc)
  make install
}
