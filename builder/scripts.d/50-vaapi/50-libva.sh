#!/bin/bash

SCRIPT_REPO="https://github.com/intel/libva.git"
SCRIPT_COMMIT="eec9f7132d4677575f929fc1dd3babc349cc56da" # 2.14.0

# Ubuntu 20.04  : 2.7.0     # c2be378312b0a17c796509defae42afba7351272
# Ubuntu 22.04  : 2.14.0    # eec9f7132d4677575f929fc1dd3babc349cc56da
# Ubuntu 24.04  : 2.20.0    # 907b2b5405ca1091b4360bf35060e143bd704b62
# Ubuntu 25.04  : 2.22.0    # 217da1c28336d6a7e9c0c4cb8f1c303968a675f1
# Debian 11     : 2.10.0    # e3c7598743f10477f5799df42c806ba4945fd5c1
# Debian 12     : 2.17.0    # df3c584bb79d1a1e521372d62fa62e8b1c52ce6c
# Debian 13     : 2.22.0    # 217da1c28336d6a7e9c0c4cb8f1c303968a675f1

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    [[ $TARGET == linuxarm64 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" libva
    cd libva

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-shared
        --disable-static
        --with-pic
        --disable-docs
        --enable-drm
        --enable-x11
        --disable-glx
        --disable-wayland
    )

    if [[ $TARGET == linux64 ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
            --with-drivers-path="/usr/lib/x86_64-linux-gnu/dri"
            --sysconfdir="/etc"
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAFS="$RAW_LDFLAGS"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    gen-implib "$FFBUILD_PREFIX"/lib/{libva.so.2,libva.a}
    gen-implib "$FFBUILD_PREFIX"/lib/{libva-drm.so.2,libva-drm.a}
    gen-implib "$FFBUILD_PREFIX"/lib/{libva-x11.so.2,libva-x11.a}
    rm "$FFBUILD_PREFIX"/lib/libva{,-drm,-x11}{.so*,.la}

    echo "Libs: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libva.pc
}

ffbuild_configure() {
    [[ $TARGET == linux* ]] && [[ $TARGET != linuxarm64 ]] && echo --enable-vaapi
}

ffbuild_unconfigure() {
    [[ $TARGET == linux* ]] && [[ $TARGET != linuxarm64 ]] && echo --disable-vaapi
}
