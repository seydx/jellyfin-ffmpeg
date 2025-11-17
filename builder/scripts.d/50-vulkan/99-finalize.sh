#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_enabled() {
    [[ $TARGET == mac* ]] && return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --from=\${SELFLAYER} \$FFBUILD_PREFIX/. \$FFBUILD_PREFIX"
    to_df "COPY --from=\${SELFLAYER} /opt/glslc /usr/bin/glslc"
}

ffbuild_dockerbuild() {
    rm "$FFBUILD_PREFIX"/lib/lib*.so* || true
    rm "$FFBUILD_PREFIX"/lib/*.la || true
}
