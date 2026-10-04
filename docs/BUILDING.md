# Building Castlevania-NX

This document records the inputs and build path used for Castlevania-NX 1.0.0. Building
requires the user's matching Xbox Live Arcade executable. Generated C++ is a translation of
that executable and must not be committed or redistributed as game data.

## Version anchors

The release was produced from these upstream points plus the Switch source changes published
with this release:

| Component | Revision |
|---|---|
| NocturneRecomp | `v1.4.5`, commit `5390d5ec91d4b0d0c87a6db35ea351343d04cd91` |
| birabittoh/ReXGlue SotN branch | commit `7766f97126a40399d76105d431ae37c802eba740`, followed by the published Horizon/SotN patch set |
| mesa-switch | commit `d4a00ea0ab3f59afb967cc5d779e4263d237bd77`, with the four published project8 Switch patches used by this release |
| FFmpeg submodule | `0604b464c7cb4ebc94940cf1f324a3b26b87717c` |
| libmspack submodule | `305907723a4e7ab2018e58040059ffb5e77db837` |

The tag for this port is `castlevania-nx-v1.0.0`. It deliberately does not look like the
upstream application's `vX.Y.Z` tags: NocturneRecomp's version logic continues to identify
the application base as 1.4.5 for mod compatibility.

## Requirements

- Linux with Docker, Git, CMake, Ninja and Python 3.
- The supplied devkitA64/libnx Switch toolchain and Docker image.
- The ReXGlue source and all of its recursive submodules.
- Mesa/NVK built for Horizon and staged as a small driver SDK containing Vulkan headers,
  `lib/libvulkan.a` and `lib/libnak_rs.a`.
- A legally obtained XBLA package whose `default.xex` matches the required SHA-256.
- Sufficient disk space and memory for 53 large generated translation units and the static
  link.

Do not use Nintendo's proprietary SDK. This port was built with the open devkitPro/libnx
toolchain.

## Verified workspace layout

The supplied wrappers mount this layout under `/work` inside the build container:

```text
work/
  castlevania-nx/
  rexglue-sdk/
  mesa/
  nvk-sdk/
    include/vulkan/
    include/vk_video/
    lib/libvulkan.a
    lib/libnak_rs.a
```

The release repository includes the tested GCC/devkitA64 configuration as
`tools/switch/switch-devkitA64.cmake`. Build the application container, whose devkitA64
base image is pinned by digest, with:

```bash
docker build -t castlevania-nx-build tools/switch
```

## 1. Extract and verify the owned game

From the NocturneRecomp source tree, its existing extractor accepts the XBLA package:

```bash
python3 scripts/extract_game.py /absolute/path/to/your-owned-package --assets assets
sha256sum assets/default.xex
```

The result must be:

```text
26a58b074c5dd6185b77a8111a0012866d11cba674b4b0810d79dbf07ad68aa6  assets/default.xex
```

`assets/`, the package and everything under `generated/` are deliberately ignored and must
never enter a source commit.

## 2. Generate the recompiled sources on the host

Use the SDK pinned by NocturneRecomp to obtain a host `rexglue` executable, then run its real
manifest:

```bash
python3 scripts/download-sdk.py sdk-host --pinned
sdk-host/bin/rexglue codegen nocturnerecomp_manifest.toml
```

The Switch CMake path requires at least `generated/sources.cmake` and
`generated/nocturnerecomp_init.h`. Code generation may stamp `sdk_version` in the manifest;
that generated value is not a source change and should not be committed.

## 3. Prepare the Horizon ReXGlue tree

Initialize every ReXGlue submodule at the revisions recorded by the source checkout. Apply
the release's ReXGlue patch series to the base in its documented order. The resulting tree
contains the Horizon runtime, memory/exception handling, Switch input and audio, WMAv2
support, shader-translation fixes and the Switch CMake helpers used by the app target.

```bash
git clone --recursive https://github.com/birabittoh/rexglue-sdk.git ../rexglue-sdk
git -C ../rexglue-sdk checkout 7766f97126a40399d76105d431ae37c802eba740
git -C ../rexglue-sdk submodule update --init --recursive
git -C ../rexglue-sdk am "$PWD/patches/rexglue-sdk/0001-switch-horizon-runtime-and-sotn-compatibility.patch"
```

The exact source, configuration and local modifications to FFmpeg and libmspack must remain
available; see [RELINKING.md](RELINKING.md).

## 4. Build and stage Mesa/NVK

The verified driver base is mesa-switch commit `d4a00ea0ab3f59afb967cc5d779e4263d237bd77`.
Apply the four project8 Switch patches used by this release in order. They provide the
verified Switch build script and the NVK/NAK changes used by the NRO.

```bash
git clone https://github.com/danfromtico/mesa-switch.git ../mesa
git -C ../mesa checkout --detach d4a00ea0ab3f59afb967cc5d779e4263d237bd77
for patch in "$PWD"/patches/mesa-switch/000*.patch; do
  git -C ../mesa apply "$patch"
done
(cd ../mesa && ./build-switch-p8.sh)
tools/switch/stage-nvk.sh ../mesa ../nvk-sdk
```

The application build consumes a driver SDK with this interface:

```text
nvk-sdk/
  include/vulkan/...
  include/vk_video/...
  lib/libvulkan.a
  lib/libnak_rs.a
```

For the validated release, the staged archives were regular, indexed AArch64 archives:

| File | Bytes | SHA-256 |
|---|---:|---|
| `lib/libvulkan.a` | 93,922,796 | `4904226fb506ac1ef95dc5eb80064f93d2e6153224d6c458dbf04f1cd2ed9131` |
| `lib/libnak_rs.a` | 33,761,108 | `b663c4f8b3f6584b9de24f8a6c7094dd37e745d4bc6d6dc79ec969def66c5074` |

Those hashes identify the release inputs; rebuilding with the same sources on another
toolchain may legitimately produce different archive bytes.

The source revisions and patches are pinned, but the build is not fully hermetic or
guaranteed byte-for-byte reproducible. In particular, Mesa's patched `Docker.rust` helper
uses rolling package repositories and Rust nightly, and its helper can reuse an existing
local `devkitpro-mesa-rust-aarch64` image tag. The application image also installs Clang
and glslang from the current repository snapshot. The hashes above and the final NRO hash
identify the exact binaries used for v1.0.0.

## 5. Configure and build the NRO

The supplied wrappers mount the application, SDK and NVK SDK at stable paths and use this
exact CMake configuration:

```bash
cmake -S /work/castlevania-nx -B /work/castlevania-nx/build-switch -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=/work/castlevania-nx/tools/switch/switch-devkitA64.cmake \
  -DREXSDK_DIR=/work/rexglue-sdk \
  -DREXGLUE_SWITCH_NVK_SDK=/work/nvk-sdk \
  -DREXGLUE_BUILD_TESTS=OFF \
  -Wno-dev

cmake --build /work/castlevania-nx/build-switch -j 6 -- -k 0
```

From the repository root, the wrappers perform those operations with:

```bash
tools/switch/configure.sh /absolute/path/to/rexglue-sdk /absolute/path/to/nvk-sdk
JOBS=6 tools/switch/build.sh /absolute/path/to/rexglue-sdk /absolute/path/to/nvk-sdk nocturnerecomp
```

The outputs are:

```text
build-switch/nocturnerecomp.nro
build-switch/nocturnerecomp          unstripped AArch64 ELF for crash symbols
build-switch/nocturnerecomp.nacp
```

Publish the NRO as `castlevania-nx.nro`; do not rename the optional config sidecar away
from `nocturnerecomp.toml`. The ZIP distribution also carries `README.txt`, the optional
CRT shader, the project license and the complete `LICENSES.txt` notice bundle.

## 6. Verify

The public 1.0.0 release NRO is:

```text
Bytes:   51,516,752
SHA-256: c9b543428c95d94bbf7f583e08d7e32a257dcc8e9267e7eb2188c34e2fd98243
```

The NRO contains `NRO0` at offset `0x10`; its NACP title is
`Castlevania: Symphony of the Night`, author `NocturneRecomp (Switch build)`, version
`1.4.5`. The gameplay and performance changes were validated on hardware before the final
public-artwork/package rebuild. The release build was followed by a second incremental
invocation that reported `ninja: no work to do`; do the same before archiving an ELF and
NRO for a hardware test.

Only the vanilla XBLA build is documented here. The released NRO is not a TU build.
