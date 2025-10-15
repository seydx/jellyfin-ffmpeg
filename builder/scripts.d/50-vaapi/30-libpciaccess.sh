#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/lib/libpciaccess.git"
SCRIPT_COMMIT="fbd1f0fe79ba25b72635f8e36a6c33d7e0ca19f6" # 0.16

# Ubuntu 20.04  : 0.16-0        # fbd1f0fe79ba25b72635f8e36a6c33d7e0ca19f6
# Ubuntu 22.04  : 0.16-3        # fbd1f0fe79ba25b72635f8e36a6c33d7e0ca19f6
# Ubuntu 24.04  : 0.17-3        # 935f0b4d6983f77c4f35e6d492f9f2c2d1ed57f9
# Ubuntu 25.04  : 0.17-3        # 935f0b4d6983f77c4f35e6d492f9f2c2d1ed57f9
# Debian 11     : 0.16-1        # fbd1f0fe79ba25b72635f8e36a6c33d7e0ca19f6
# Debian 12     : 0.17-2        # 935f0b4d6983f77c4f35e6d492f9f2c2d1ed57f9
# Debian 13     : 0.17-3        # 935f0b4d6983f77c4f35e6d492f9f2c2d1ed57f9

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" libpciaccess
    cd libpciaccess

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=shared
        -Dzlib=enabled
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

    meson setup "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install

    gen-implib "$FFBUILD_PREFIX"/lib/{libpciaccess.so.0,libpciaccess.a}
    rm "$FFBUILD_PREFIX"/lib/libpciaccess.so*

    echo "Libs: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/pciaccess.pc
}
