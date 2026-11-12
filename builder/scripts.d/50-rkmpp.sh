#!/bin/bash

SCRIPT_REPO="https://github.com/nyanmisaka/rk-mirrors.git"
SCRIPT_COMMIT="848b885f95587994a53216e435f650041a894e31"
SCRIPT_BRANCH="jellyfin-mpp-next"

ffbuild_enabled() {
    [[ $TARGET == linux* ]] && [[ $TARGET == *arm64 ]] && return 0
    return -1
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" rkmpp
    cd rkmpp

    # kmpp.h uses struct timeval without <sys/time.h>, which glibc pulls in indirectly but musl doesn't
    if [[ $TARGET == linuxmusl* ]]; then
        sed -i 's|#include <unistd.h>|#include <sys/time.h>\n#include <unistd.h>|' kmpp/inc/kmpp.h
    fi

    mkdir rkmpp_build && cd rkmpp_build

    cmake -GNinja \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_TEST=OFF \
        -DBUILD_SHARED_LIBS=OFF ..

    ninja -j$(nproc)
    ninja install

    echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/rockchip_mpp.pc
}

ffbuild_configure() {
    echo --enable-rkmpp
}

ffbuild_unconfigure() {
    [[ $TARGET != linux* ]] && return 0
    [[ $TARGET != *arm64 ]] && return 0
    echo --disable-rkmpp
}
