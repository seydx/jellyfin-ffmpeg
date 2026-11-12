/**
 * Graceful dlopen callback for implib-gen
 *
 * Instead of asserting/crashing when a library cannot be loaded,
 * this callback returns NULL which allows FFmpeg to handle the
 * error gracefully and return an appropriate error code.
 */

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

/**
 * Custom dlopen callback that handles missing libraries gracefully.
 * Returns NULL if the library cannot be loaded, instead of crashing.
 */
void *implib_dlopen_callback(const char *lib_name) {
    void *handle = dlopen(lib_name, RTLD_LAZY | RTLD_LOCAL);
    if (!handle) {
        // Library not found - return NULL gracefully instead of crashing
        // FFmpeg will handle this as an error and return appropriate error code
        const char *err = dlerror();
        if (getenv("IMPLIB_DEBUG")) {
            fprintf(stderr, "implib: %s: %s (graceful fallback)\n",
                    lib_name, err ? err : "unknown error");
        }
        return NULL;
    }
    return handle;
}
