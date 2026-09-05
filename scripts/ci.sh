#!/bin/sh

# What the build job runs, from a clean tree as CI gets it. The toolchain comes from the
# dev container, so run it there.

set -e

cd "$(dirname "$0")/../"

make clean
make dist
