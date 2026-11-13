# LGPL v3: the gpl defaults without --enable-gpl. x264, x265, fftw3f and chromaprint
# (which links fftw3f) disable themselves for lgpl* variants.
source "$(dirname "$BASH_SOURCE")"/defaults-gpl.sh

FF_CONFIGURE="${FF_CONFIGURE/--enable-gpl /}"
LICENSE_FILE="COPYING.LGPLv3"

# libfdk_aac comes with its own license (Fraunhofer FDK AAC), so lgpl leaves it out and
# stays plain LGPL. FFmpeg's own aac encoder and decoder remain.
FF_SKIP_SCRIPTS=(
    50-fdk-aac-stripped
)
