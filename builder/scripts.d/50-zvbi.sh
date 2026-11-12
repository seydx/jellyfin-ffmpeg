#!/bin/bash

SCRIPT_REPO="https://github.com/zapping-vbi/zvbi.git"
SCRIPT_COMMIT="41477c97c8edf7a01f1594b2a95b94f0117eed21"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" zvbi
    cd zvbi

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --without-doxygen
        --without-x
        --disable-dvb
        --disable-bktr
        --disable-nls
        --disable-proxy
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    elif [[ $TARGET == mac* ]]; then
        :
    else
        echo "Unknown target"
        return -1
    fi

    # Cross-compiling, autoconf can't run its malloc(0) test and only trusts glibc hosts, so
    # for musl it maps malloc to an rpl_malloc that zvbi doesn't ship. musl's malloc(0) is fine.
    if [[ $TARGET == linuxmusl* ]]; then
        myconf+=(
            ac_cv_func_malloc_0_nonnull=yes
            ac_cv_func_realloc_0_nonnull=yes
        )
    fi

    ./configure "${myconf[@]}"
    make -C src -j$(nproc)
    make -C src install
    make SUBDIRS=. install
}

ffbuild_configure() {
    echo --enable-libzvbi
}

ffbuild_unconfigure() {
    echo --disable-libzvbi
}
