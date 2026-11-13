# light: the gpl build without the less common external libraries (whisper, libplacebo,
# AV1 and VP8/VP9 encoders, JPEG XL, subtitles, tracker music, ...). Every internal FFmpeg
# component stays, so the CLI still runs any command that doesn't need one of them.
source "$(dirname "$BASH_SOURCE")"/defaults-gpl.sh

FF_SKIP_SCRIPTS=(
    25-fftw3f
    25-gmp
    25-libogg
    45-lcms2
    45-libudfread
    45-libunibreak
    45-libvorbis
    50-chromaprint
    50-libass
    50-libbluray
    50-libjxl
    50-libplacebo
    50-libtheora
    50-libvpx
    50-libwebp
    50-openmpt
    50-srt
    50-svtav1
    50-zimg
    50-zvbi
    60-whisper
)
