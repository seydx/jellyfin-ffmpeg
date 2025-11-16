#!/bin/bash

SCRIPT_REPO="https://github.com/BtbN/Vulkan-Shim-Loader.git"
SCRIPT_COMMIT="9657ca8e395ef16c79b57c8bd3f4c1aebb319137"

ffbuild_enabled() {
    [[ $TARGET == mac* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" vulkan-loader
    cd vulkan-loader

    mkdir build && cd build

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DVULKAN_SHIM_IMPERSONATE=ON \
        ..
    ninja -j$(nproc)
    ninja install
}
