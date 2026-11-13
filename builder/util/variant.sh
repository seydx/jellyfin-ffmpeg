#!/bin/bash

# Whether the variant builds and links a scripts.d entry. On top of the script's own
# ffbuild_enabled, a variant leaves whole entries out through FF_SKIP_SCRIPTS (names
# below scripts.d without .sh, a directory name covers everything in it).
script_enabled() {
    local name="${1#scripts.d/}"
    name="${name%.sh}"
    local skip
    for skip in "${FF_SKIP_SCRIPTS[@]}"; do
        [[ "$name" == "$skip" || "$name" == "$skip"/* ]] && return 1
    done
    ffbuild_enabled
}
