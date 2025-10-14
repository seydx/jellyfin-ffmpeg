#!/bin/bash

SCRIPT_REPO="https://github.com/ggml-org/whisper.cpp.git"
SCRIPT_COMMIT="a91dd3be72f70dd1b3cb6e252f35fa17b93f596c"

ffbuild_enabled() {
    return -1
    # [[ $TARGET == *32 ]] && return -1
    # return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" whisper
    cd whisper

    mkdir build && cd build

    local myconf=(
        -GNinja
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN"
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX"
        -DBUILD_SHARED_LIBS=OFF
        -DWHISPER_BUILD_TESTS=OFF
        -DWHISPER_BUILD_EXAMPLES=OFF
        -DWHISPER_BUILD_SERVER=OFF
        -DWHISPER_USE_SYSTEM_GGML=OFF
        -DGGML_CCACHE=OFF
        -DGGML_NATIVE=OFF
        -DGGML_SSE42=ON
        -DGGML_AVX=ON
        -DGGML_F16C=ON
        -DGGML_AVX2=ON
        -DGGML_BMI2=ON
        -DGGML_FMA=ON
    )

    # Platform-specific acceleration
    if [[ $TARGET != mac* ]]; then
        myconf+=(-DGGML_VULKAN=ON)
        myconf+=(-DGGML_OPENCL=ON)
    else
        myconf+=(-DGGML_VULKAN=OFF)
        myconf+=(-DGGML_OPENCL=OFF)
        myconf+=(-DGGML_METAL=ON)
    fi

    cmake "${myconf[@]}" ..

    ninja -j$(nproc)
    ninja install

    # Fix pkg-config file
    sed -i -e 's/^\(Libs:\).*$/\1 -L${libdir} -lwhisper/' "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc

    # Add private libs based on what was actually built
    if [[ $TARGET != mac* ]]; then
        echo "Libs.private: -lggml -lggml-base -lggml-cpu -lggml-vulkan -lggml-opencl -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc
        echo "Requires: vulkan OpenCL" >> "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc
    else
        echo "Libs.private: -lggml -lggml-base -lggml-cpu -lggml-metal -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc
    fi
}

ffbuild_configure() {
    echo --enable-whisper
}

ffbuild_unconfigure() {
    [[ $TARGET == *32 ]] && return 0
    echo --disable-whisper
}