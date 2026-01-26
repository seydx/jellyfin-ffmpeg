#!/bin/bash
set -e
if [[ $# != 2 ]]; then
    echo "Invalid arguments"
    exit 1
fi
IN="$1"
OUT="$2"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CALLBACK_FILE="$SCRIPT_DIR/../implib-graceful-callback.c"

TMPDIR="$(mktemp -d)"
trap "rm -rf '$TMPDIR'" EXIT
cd "$TMPDIR"

set -x

# Copy and compile the graceful callback
cp "$CALLBACK_FILE" .
${FFBUILD_CROSS_PREFIX}gcc $CFLAGS $STAGE_CFLAGS -Wa,--noexecstack -c implib-graceful-callback.c -o implib-graceful-callback.o

# Generate implib stubs with custom dlopen callback for graceful error handling
python3 /opt/implib/implib-gen.py --target aarch64-linux-gnu --dlopen --lazy-load --verbose --dlopen-callback=implib_dlopen_callback "$IN"
${FFBUILD_CROSS_PREFIX}gcc $CFLAGS $STAGE_CFLAGS -Wa,--noexecstack -DIMPLIB_HIDDEN_SHIMS -c *.tramp.S *.init.c

# Include the callback object in the archive
${FFBUILD_CROSS_PREFIX}ar -rcs "$OUT" *.tramp.o *.init.o implib-graceful-callback.o
