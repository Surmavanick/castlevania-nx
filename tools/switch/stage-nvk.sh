#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 /absolute/path/to/mesa /absolute/path/to/nvk-sdk" >&2
  exit 2
fi

mesa_dir=$(realpath "$1")
sdk_dir=$(realpath -m "$2")
vulkan_archive="$mesa_dir/builddir-switch/src/nouveau/vulkan/libvulkan.a"
nak_archive="$mesa_dir/builddir-switch/src/nouveau/compiler/libnak_rs.a"

test -f "$vulkan_archive"
test -f "$nak_archive"

if [[ -e "$sdk_dir/include/vulkan" || -e "$sdk_dir/include/vk_video" || \
      -e "$sdk_dir/lib/libvulkan.a" || -e "$sdk_dir/lib/libnak_rs.a" ]]; then
  echo "error: destination already contains staged NVK files: $sdk_dir" >&2
  echo "use a new or empty destination directory" >&2
  exit 1
fi

mkdir -p "$sdk_dir/lib" "$sdk_dir/include"
cp "$vulkan_archive" "$sdk_dir/lib/libvulkan.a"
cp "$nak_archive" "$sdk_dir/lib/libnak_rs.a"
cp -a "$mesa_dir/include/vulkan" "$sdk_dir/include/"
cp -a "$mesa_dir/include/vk_video" "$sdk_dir/include/"

docker run --rm -u "$(id -u):$(id -g)" \
  -v "$sdk_dir:/sdk" \
  devkitpro/devkita64@sha256:1fc388c3a0d34bd2045a6dadcb1020e069d5f876a187fd705de14b4440c00282 \
  /opt/devkitpro/devkitA64/bin/aarch64-none-elf-ranlib /sdk/lib/libvulkan.a

sha256sum "$sdk_dir/lib/libvulkan.a" "$sdk_dir/lib/libnak_rs.a"
