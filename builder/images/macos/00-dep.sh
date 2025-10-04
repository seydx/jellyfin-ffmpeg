#!/bin/bash

ffbuild_macbase() {
  # https://github.com/actions/runner-images/issues/12912
  # uninstalled pinned cmake as we are ready for cmake 4.x already
  brew list cmake && brew uninstall cmake
  brew install wget subversion mercurial autoconf automake cmake meson ninja pkg-config coreutils gcc make python-setuptools pcre2 libtool gnu-sed gnu-tar quilt texinfo
  # Pin nasm to 2.16.03 to avoid dav1d AVX512 assembly issues with nasm 3.0.0
  # https://code.videolan.org/videolan/dav1d/-/issues/457
  brew unlink nasm 2>/dev/null || true
  wget -O /tmp/nasm.rb https://raw.githubusercontent.com/Homebrew/homebrew-core/8197abd5ad0f893bbc7b99f20cd09b50a4b8f446/Formula/n/nasm.rb
  brew install --build-from-source /tmp/nasm.rb
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
