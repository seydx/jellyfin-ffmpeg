#!/bin/bash

SCRIPT_REPO="https://github.com/alsa-project/alsa-lib.git"
SCRIPT_COMMIT="75ed5f05babcae7515aff5277e038ffd854c7669"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" alsa-lib
    cd alsa-lib

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --host="$FFBUILD_TOOLCHAIN"
        --enable-static
        --disable-shared
        --disable-old-symbols
        --disable-python
        --disable-rawmidi
        --disable-hwdep
        --disable-seq
        --disable-ucm
        --disable-topology
        --disable-alisp
        --with-configdir=/usr/share/alsa
        --with-pcm-plugins=hw
        --without-debug
        --without-versioned
    )

    # -fPIC: Required for linking into shared objects (Node.js addons / .node files).
    # -UPIC: Undefine the PIC preprocessor macro so ALSA's source code takes the
    #        static symbol resolution path (#ifndef PIC) in dlmisc.c and all
    #        *_symbols.c / *_hw.c files. Without this, ALSA uses dlopen(NULL)
    #        which crashes when statically linked into PIE binaries or .node files.
    export CFLAGS="$RAW_CFLAGS -fPIC -UPIC"
    export LDFLAGS="$RAW_LDFLAGS"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-indev=alsa
}

ffbuild_unconfigure() {
    echo --disable-indev=alsa
}
