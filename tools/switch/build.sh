#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 /absolute/path/to/rexglue-sdk /absolute/path/to/nvk-sdk [target ...]" >&2
  exit 2
fi

repo_dir=$(cd "$(dirname "$0")/../.." && pwd)
sdk_dir=$(realpath "$1")
nvk_dir=$(realpath "$2")
shift 2
jobs=${JOBS:-6}
target_args=()
if [[ $# -gt 0 ]]; then
  target_args=(--target "$@")
fi

docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp \
  -v "$repo_dir:/work/castlevania-nx" \
  -v "$sdk_dir:/work/rexglue-sdk" \
  -v "$nvk_dir:/work/nvk-sdk" \
  castlevania-nx-build \
  cmake --build /work/castlevania-nx/build-switch -j "$jobs" "${target_args[@]}" -- -k 0
