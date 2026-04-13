#!/bin/bash

SCRIPT_REPO="https://github.com/libjxl/libjxl.git"
SCRIPT_COMMIT="8ce9537c989cfc7adff034556c8a4b9469e874d6"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone "$SCRIPT_REPO" libjxl
    cd libjxl
    git checkout "$SCRIPT_COMMIT"
    git submodule update --init --recursive --depth 1 --recommend-shallow third_party/highway

    mkdir build && cd build

    if [[ $TARGET == mac* ]]; then
        cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
            -DJPEGXL_ENABLE_SKCMS=OFF -DJPEGXL_FORCE_SYSTEM_LCMS2=ON \
            -DBUILD_SHARED_LIBS=OFF -DJPEGXL_STATIC=OFF -DJPEGXL_ENABLE_TOOLS=OFF -DJPEGXL_ENABLE_VIEWERS=OFF -DJPEGXL_EMSCRIPTEN=OFF -DJPEGXL_ENABLE_DOXYGEN=OFF \
            -DJPEGXL_ENABLE_JPEGLI=OFF -DBUILD_TESTING=OFF -DJPEGXL_ENABLE_EXAMPLES=OFF -DJPEGXL_ENABLE_MANPAGES=OFF -DJPEGXL_ENABLE_JNI=OFF -DJPEGXL_ENABLE_PLUGINS=OFF \
            -DJPEGXL_ENABLE_DEVTOOLS=OFF -DJPEGXL_ENABLE_BENCHMARK=OFF -DJPEGXL_BUNDLE_LIBPNG=OFF -DJPEGXL_ENABLE_SJPEG=OFF -DJPEGXL_FORCE_SYSTEM_BROTLI=ON ..
    elif [[ $TARGET == linux* ]]; then
        # our glibc is too old(<2.25), and their detection fails for some reason
        export CXXFLAGS="$CXXFLAGS -DVQSORT_GETRANDOM=0 -DVQSORT_SECURE_SEED=0"
        cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
            -DJPEGXL_ENABLE_SKCMS=OFF -DJPEGXL_FORCE_SYSTEM_LCMS2=ON \
            -DBUILD_SHARED_LIBS=OFF -DJPEGXL_STATIC=OFF -DJPEGXL_ENABLE_TOOLS=OFF -DJPEGXL_ENABLE_VIEWERS=OFF -DJPEGXL_EMSCRIPTEN=OFF -DJPEGXL_ENABLE_DOXYGEN=OFF \
            -DJPEGXL_ENABLE_JPEGLI=OFF -DBUILD_TESTING=OFF -DJPEGXL_ENABLE_EXAMPLES=OFF -DJPEGXL_ENABLE_MANPAGES=OFF -DJPEGXL_ENABLE_JNI=OFF -DJPEGXL_ENABLE_PLUGINS=OFF \
            -DJPEGXL_ENABLE_DEVTOOLS=OFF -DJPEGXL_ENABLE_BENCHMARK=OFF -DJPEGXL_BUNDLE_LIBPNG=OFF -DJPEGXL_ENABLE_SJPEG=OFF -DJPEGXL_FORCE_SYSTEM_BROTLI=ON ..
    elif [[ $TARGET == win* ]]; then
        # Fix AVX2 related crash due to unaligned stack memory
        export CXXFLAGS="$CXXFLAGS -Wa,-muse-unaligned-vector-move"
        export CFLAGS="$CFLAGS -Wa,-muse-unaligned-vector-move"
        cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
            -DJPEGXL_ENABLE_SKCMS=OFF -DJPEGXL_FORCE_SYSTEM_LCMS2=ON \
            -DBUILD_SHARED_LIBS=OFF -DJPEGXL_STATIC=OFF -DJPEGXL_ENABLE_TOOLS=OFF -DJPEGXL_ENABLE_VIEWERS=OFF -DJPEGXL_EMSCRIPTEN=OFF -DJPEGXL_ENABLE_DOXYGEN=OFF \
            -DJPEGXL_ENABLE_JPEGLI=OFF -DBUILD_TESTING=OFF -DJPEGXL_ENABLE_EXAMPLES=OFF -DJPEGXL_ENABLE_MANPAGES=OFF -DJPEGXL_ENABLE_JNI=OFF -DJPEGXL_ENABLE_PLUGINS=OFF \
            -DJPEGXL_ENABLE_DEVTOOLS=OFF -DJPEGXL_ENABLE_BENCHMARK=OFF -DJPEGXL_BUNDLE_LIBPNG=OFF -DJPEGXL_ENABLE_SJPEG=OFF -DJPEGXL_FORCE_SYSTEM_BROTLI=ON ..
    fi

    ninja -j$(nproc)

    ninja install

    if [[ $TARGET == win* ]]; then
        echo "Libs.private: -lstdc++ -ladvapi32" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libjxl.pc
        echo "Libs.private: -lstdc++ -ladvapi32" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libjxl_threads.pc
    else
        echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libjxl.pc
        echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libjxl_threads.pc
    fi

    echo "Requires.private: lcms2" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libjxl_cms.pc
}

ffbuild_configure() {
    echo --enable-libjxl
}

ffbuild_unconfigure() {
    echo --disable-libjxl
}
