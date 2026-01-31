FF_CONFIGURE="--enable-gpl --enable-version3 --disable-ffplay --disable-debug --disable-doc --disable-sdl2"
FF_CFLAGS=""
FF_CXXFLAGS=""
FF_LDFLAGS=""
GIT_BRANCH="jellyfin"
LICENSE_FILE="COPYING.GPLv3"

[[ $TARGET == linux* ]] && FF_CONFIGURE+=" --enable-lto=auto" || true
# [[ $TARGET == win* ]] && FF_CONFIGURE+=" --enable-lto=auto" || true
[[ $TARGET == mac* ]] && FF_CONFIGURE+=" --enable-lto=thin" || true

# Enable input devices for device capture (webcam, microphone, screen)
[[ $TARGET == linux* ]] && FF_CONFIGURE+=" --enable-indev=v4l2 --enable-indev=alsa --enable-indev=xcbgrab" || true
[[ $TARGET == win* ]] && FF_CONFIGURE+=" --enable-indev=dshow --enable-indev=gdigrab" || true
[[ $TARGET == mac* ]] && FF_CONFIGURE+=" --enable-indev=avfoundation" || true