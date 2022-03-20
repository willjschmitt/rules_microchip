# This is based on https://ltekieli.com/cross-compiling-with-bazel/, where this
# simple wrapper helps with the problem of relative pathing in the execution of
# tools/tool_paths in a cc_toolchain definition.
#!/bin/bash

NAME=$(basename "$0")
TOOLCHAIN_BINDIR=external/xc32/bin

exec "${TOOLCHAIN_BINDIR}"/"${NAME}" "$@"