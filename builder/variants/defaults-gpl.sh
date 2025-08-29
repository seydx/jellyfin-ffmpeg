FF_CONFIGURE="--enable-gpl --enable-version3 --disable-ffplay --disable-debug --disable-doc --disable-sdl2"
FF_CFLAGS=""
FF_CXXFLAGS=""
FF_LDFLAGS=""
GIT_BRANCH="jellyfin"
LICENSE_FILE="COPYING.GPLv3"

# Node-av modifications: Use PIC for Linux builds, disable LTO for Linux
[[ $TARGET == linux* ]] && FF_CONFIGURE+=" --disable-libxcb --disable-xlib --enable-pic" || true
# [[ $TARGET == win* ]] && FF_CONFIGURE+=" --enable-lto=auto" || true
[[ $TARGET == mac* ]] && FF_CONFIGURE+=" --enable-lto=thin" || true

# Force PIC for shared library compatibility on Linux
if [[ $TARGET == linux* ]]; then
    FF_CFLAGS="${FF_CFLAGS} -fPIC -DPIC"
    FF_CXXFLAGS="${FF_CXXFLAGS} -fPIC -DPIC"
    FF_LDFLAGS="${FF_LDFLAGS} -fPIC"
    FF_ASFLAGS="${FF_ASFLAGS} -DPIC"
    export FF_CFLAGS FF_CXXFLAGS FF_LDFLAGS FF_ASFLAGS
fi
