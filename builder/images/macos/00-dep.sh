#!/bin/bash

ffbuild_macbase() {
  # https://github.com/actions/runner-images/issues/12912
  # uninstalled pinned cmake as we are ready for cmake 4.x already
  brew list cmake && brew uninstall cmake
  brew install wget subversion mercurial autoconf automake cmake meson ninja pkg-config coreutils gcc make python-setuptools pcre2 libtool gnu-sed gnu-tar quilt texinfo
  # Pin nasm to 2.16.03 to avoid dav1d AVX512 assembly issues with nasm 3.0.0
  # https://code.videolan.org/videolan/dav1d/-/issues/457
  brew unlink nasm 2>/dev/null || true
  export HOMEBREW_NO_INSTALL_FROM_API=1
  brew tap --force homebrew/core
  brew tap-new --no-git local/nasm
  brew extract --version=2.16.03 nasm local/nasm
  brew install --build-from-source local/nasm/nasm@2.16.03
  brew untap local/nasm
  unset HOMEBREW_NO_INSTALL_FROM_API
  mkdir /opt/ffbuild/bin
  cp "$BUILDER_ROOT"/images/base/git-mini-clone.sh /opt/ffbuild/bin/git-mini-clone
  chmod +x /opt/ffbuild/bin/git-mini-clone
  cp "$BUILDER_ROOT"/images/base/retry-tool.sh /opt/ffbuild/bin/retry-tool
  chmod +x /opt/ffbuild/bin/retry-tool
  cp "$BUILDER_ROOT"/images/base/check-wget.sh /opt/ffbuild/bin/check-wget
  chmod +x /opt/ffbuild/bin/check-wget
  export PATH="/opt/ffbuild/bin:$PATH"
  export CMAKE_POLICY_VERSION_MINIMUM="3.5"
}
