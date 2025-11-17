#!/bin/bash

SCRIPT_REPO="https://github.com/ggml-org/whisper.cpp.git"
SCRIPT_COMMIT="d9b7613b34a343848af572cc14467fc5e82fc788"

ffbuild_enabled() {
    [[ $TARGET != *32 ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" whisper
    cd whisper

    mkdir build && cd build

    local myconf=(
        -GNinja
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN"
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX"
        -DCMAKE_BUILD_TYPE=Release
        -DBUILD_SHARED_LIBS=OFF
        -DWHISPER_BUILD_TESTS=OFF
        -DWHISPER_BUILD_EXAMPLES=OFF
        -DWHISPER_BUILD_SERVER=OFF
        -DWHISPER_USE_SYSTEM_GGML=OFF
        -DGGML_CCACHE=OFF
        -DGGML_NATIVE=OFF
    )

    if [[ $TARGET == linux* || $TARGET == win* ]]; then
        # Linux/Windows: Use Vulkan and OpenCL
        myconf+=(
            -DGGML_OPENCL=ON
            -DGGML_VULKAN=ON
            -DGGML_SSE42=ON
            -DGGML_AVX=ON
            -DGGML_F16C=ON
            -DGGML_AVX2=ON
            -DGGML_BMI2=ON
            -DGGML_FMA=ON
        )
    elif [[ $TARGET == mac* ]]; then
        # macOS: Use Metal (native GPU acceleration)
        myconf+=(
            -DGGML_METAL=ON
            -DGGML_OPENCL=OFF
            -DGGML_VULKAN=OFF
        )

        # Add CPU optimizations for x64
        if [[ $TARGET == mac64 ]]; then
            myconf+=(
                -DGGML_SSE42=ON
                -DGGML_AVX=ON
                -DGGML_F16C=ON
                -DGGML_AVX2=ON
                -DGGML_BMI2=ON
                -DGGML_FMA=ON
            )
        fi
    fi

    cmake "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install

    # Fix library prefix on Windows if needed
    shopt -s nullglob
    for libfile in "$FFBUILD_PREFIX"/lib/ggml*.a; do
        if [[ ! -f "$(dirname "${libfile}")/lib$(basename "${libfile}")" ]]; then
            mv "${libfile}" "$(dirname "${libfile}")/lib$(basename "${libfile}")"
        fi
    done

    # Fix pkg-config file for correct linking order
    if [[ -f "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc ]]; then
        echo "=== whisper.pc BEFORE modifications ==="
        cat "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc
        echo "=== END ==="

        if [[ $TARGET == mac* ]]; then
            gsed -i -e 's/^\(Libs:\).*$/\1 -L${libdir} -lwhisper/' "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc
            echo "Libs.private: -lggml -lggml-base -lggml-cpu -lggml-blas -lggml-metal -lstdc++ -framework Accelerate -framework Metal -framework Foundation -framework MetalKit" >> "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc
        else
            sed -i -e 's/^\(Libs:\).*$/\1 -L${libdir} -lwhisper/' "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc
            echo "Libs.private: -lggml -lggml-base -lggml-cpu -lggml-vulkan -lggml-opencl -lstdc++ -lgomp" >> "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc
            echo "Requires: vulkan OpenCL" >> "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc
        fi

        echo "=== whisper.pc AFTER modifications ==="
        cat "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc
        echo "=== END ==="

        echo "=== Testing pkg-config ==="
        PKG_CONFIG_PATH="$FFBUILD_PREFIX/lib/pkgconfig" pkg-config --exists --print-errors "whisper >= 1.7.5" && echo "SUCCESS: pkg-config can find whisper >= 1.7.5" || echo "FAILED: pkg-config cannot find whisper >= 1.7.5"
        PKG_CONFIG_PATH="$FFBUILD_PREFIX/lib/pkgconfig" pkg-config --modversion whisper || echo "FAILED: cannot get version"
        echo "Testing with --static flag (as FFmpeg does):"
        PKG_CONFIG_PATH="$FFBUILD_PREFIX/lib/pkgconfig" pkg-config --static --libs whisper || echo "FAILED: cannot get static libs"
        echo "=== END ==="
    fi
}

ffbuild_configure() {
    echo --enable-whisper
}

ffbuild_unconfigure() {
    echo --disable-whisper
}
