#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/mesa/drm.git"
SCRIPT_COMMIT="76a1e97a9a7c29fa3035bb370d654791bdc23d90"

# Ubuntu 20.04  : 2.4.107               # 9cef5dee3cd817728c83aeb3c2010c1954e4c402
# Ubuntu 22.04  : 2.4.113               # fb5c0c301aa9b6d984ffee522775ca19ea7c7be6
# Ubuntu 24.04  : 2.4.122               # ad78bb591d02162d3b90890aa4d0a238b2a37cde
# Ubuntu 25.04  : 2.4.124               # 38ec7dbd4df3141441afafe5ac62dfc9df36a77e
# Debian 11     : 2.4.104               # a55042e2c677e907da87e523a31682f15a86a30b
# Debian 12     : 2.4.114 / 2.4.123     # b9ca37b3134861048986b75896c0915cbf2e97f9 / 25dec5b91fe4d2638787d033a0b22b6c1dc145e0
# Debian 13     : 2.4.124               # 38ec7dbd4df3141441afafe5ac62dfc9df36a77e

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" libdrm
    cd libdrm

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        -Ddefault_library=shared
        -Dudev=false
        -Dcairo-tests=disabled
        -Dvalgrind=disabled
        -Dexynos=disabled
        -Dfreedreno=disabled
        -Domap=disabled
        -Detnaviv=disabled
        -Dintel=enabled
        -Dnouveau=enabled
        -Dradeon=enabled
        -Damdgpu=enabled
    )

    if [[ $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAFS="$RAW_LDFLAGS"

    meson "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install

    gen-implib "$FFBUILD_PREFIX"/lib/{libdrm.so.2,libdrm.a}
    rm "$FFBUILD_PREFIX"/lib/libdrm*.so*

    echo "Libs: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libdrm.pc
}

ffbuild_configure() {
    [[ $TARGET == linux* ]] && echo --enable-libdrm
}

ffbuild_unconfigure() {
    [[ $TARGET == linux* ]] && echo --disable-libdrm
}
