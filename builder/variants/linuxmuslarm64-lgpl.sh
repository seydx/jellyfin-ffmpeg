#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/default-install.sh
source "$(dirname "$BASH_SOURCE")"/defaults-lgpl.sh

# musl gives threads created without attributes only 128 KiB of stack, too little for the
# codec threads. The CLI raises that default through its PT_GNU_STACK size.
FF_LDEXEFLAGS+=" -Wl,-z,stack-size=2097152"
