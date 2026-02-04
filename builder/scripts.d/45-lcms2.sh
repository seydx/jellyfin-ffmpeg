#!/bin/bash

SCRIPT_REPO="https://github.com/mm2/Little-CMS.git"
SCRIPT_COMMIT="6ae7e97cc1b0a44f1996d51160de9fbab97bb7b8"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone "$SCRIPT_REPO" lcms2
    cd lcms2
    git checkout "$SCRIPT_COMMIT"

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        -Ddefault_library=static
        -Dutils=false
        -Dfastfloat=true
        -Dthreaded=true
    )

    if [[ $TARGET == mac* ]]; then
        : # no cross-file needed for macOS
    elif [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    if [[ $TARGET != mac* ]]; then
        export CFLAGS="$CFLAGS -fpermissive"
    fi

    meson setup "${myconf[@]}" ..
    ninja -j$(nproc)

    ninja install
}
