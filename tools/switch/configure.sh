#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 /absolute/path/to/rexglue-sdk /absolute/path/to/nvk-sdk" >&2
  exit 2
fi

repo_dir=$(cd "$(dirname "$0")/../.." && pwd)
sdk_dir=$(realpath "$1")
nvk_dir=$(realpath "$2")

docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp \
  -v "$repo_dir:/work/castlevania-nx" \
  -v "$sdk_dir:/work/rexglue-sdk" \
  -v "$nvk_dir:/work/nvk-sdk" \
  castlevania-nx-build \
  cmake -S /work/castlevania-nx -B /work/castlevania-nx/build-switch -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE=/work/castlevania-nx/tools/switch/switch-devkitA64.cmake \
    -DREXSDK_DIR=/work/rexglue-sdk \
    -DREXGLUE_SWITCH_NVK_SDK=/work/nvk-sdk \
    -DREXGLUE_BUILD_TESTS=OFF \
    -Wno-dev
