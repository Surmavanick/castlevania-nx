# Third-party notices

Castlevania-NX is built on other open-source projects. Their licenses continue to apply to
their code and to portions derived from them. This document identifies the material in the
source and the libraries linked into the NRO. The complete texts distributed with the
binary are in [NOTICE](NOTICE) and the [LICENSES](LICENSES) directory.

The corresponding source tag and binary distribution must retain the applicable copyright
and license texts. See [docs/RELINKING.md](docs/RELINKING.md) for the statically linked LGPL
libraries.

## Projects this port is derived from

| Project | Use in Castlevania-NX | License |
|---|---|---|
| [NocturneRecomp](https://github.com/birabittoh/NocturneRecomp) | Application, hooks, native renderer and code-generation configuration; release based on upstream `v1.4.5`, commit `5390d5ec91d4b0d0c87a6db35ea351343d04cd91` | MIT |
| [ReXGlue SDK](https://github.com/rexglue/rexglue-sdk) and [birabittoh/rexglue-sdk](https://github.com/birabittoh/rexglue-sdk) | Static recompiler, Xbox 360 runtime, shader translation and the Horizon platform layer | BSD-3-Clause; includes Xenia notices |
| [Xenia](https://github.com/xenia-project/xenia) | Portions of the runtime on which ReXGlue is based | BSD-3-Clause |
| [project8-sw](https://github.com/R-drg/project8-sw) | Reusable BSD-licensed ReXGlue Horizon work, MIT-licensed Mesa patches, build methods and Switch measurements | BSD-3-Clause and MIT for the reused components, as marked upstream |
| [nfsmw-nx](https://github.com/StevensND/nfsmw-nx) | Earlier Switch/ReXGlue renderer design, Horizon work and Mesa optimization research | Licenses are preserved per component; see its source and notices |
| [mesa-switch](https://github.com/danfromtico/mesa-switch) and [Mesa](https://mesa3d.org) | NVK Vulkan driver and NAK shader compiler, based on mesa-switch commit `d4a00ea0ab3f59afb967cc5d779e4263d237bd77` | MIT and other permissive licenses on individual Mesa files |
| [devkitPro](https://devkitpro.org), [libnx](https://github.com/switchbrew/libnx) and switchbrew | AArch64 toolchain and Horizon system interface | Tool/runtime licenses; libnx is ISC |

The Castlevania-NX application changes retain NocturneRecomp's MIT license. ReXGlue changes
retain its BSD-3-Clause notice. Mesa changes retain the licenses of the files they modify.

## Libraries linked into the NRO

The release link includes the following components. Header-only dependencies are listed too
when their implementation becomes part of the executable.

| Component | License |
|---|---|
| FFmpeg `libavcodec` and `libavutil`, fork commit `0604b464c7cb4ebc94940cf1f324a3b26b87717c` | LGPL-2.1-or-later |
| libmspack, commit `305907723a4e7ab2018e58040059ffb5e77db837` | LGPL-2.1 |
| ReXGlue SDK and Xenia-derived runtime | BSD-3-Clause |
| Mesa NVK/NAK through mesa-switch | MIT and other permissive per-file licenses |
| libnx | ISC |
| Expat | MIT |
| zlib | zlib License |
| Zstandard | BSD-3-Clause / GPLv2 dual license; the permissive option applies |
| glslang | BSD-3-Clause and other notices included upstream |
| SPIRV-Tools | Apache-2.0 |
| SPIRV-Headers and Vulkan-Headers | MIT / Apache-2.0 |
| SPIRV-Cross | Apache-2.0 |
| Vulkan Memory Allocator | MIT |
| xxHash | BSD-2-Clause |
| fmt, spdlog, miniz, Dear ImGui, o1heap, SIMDe, toml++, inja | MIT or equivalent permissive licenses, as supplied upstream |
| CLI11 | BSD-3-Clause |
| UTF8-CPP | Boost Software License 1.0 |
| AES-128 implementation | MIT |
| newlib 4.6.0.20260123 | Permissive notices collected in [COPYING.NEWLIB](LICENSES/switch/runtime/newlib-COPYING.NEWLIB) |
| GCC 15.2.0 libstdc++ and libgcc runtime portions | [GPLv3](LICENSES/switch/runtime/gcc-COPYING3) with the [GCC Runtime Library Exception 3.1](LICENSES/switch/runtime/gcc-COPYING.RUNTIME) |
| Rust standard library from nightly 1.101.0 (`0abfedbc7`) used by NAK | MIT or Apache-2.0, with the exact generated [library copyright inventory](LICENSES/switch/runtime/rust/COPYRIGHT-library.html) and its [referenced license texts](LICENSES/switch/runtime/rust/licenses) |
| rustc-hash 2.1.1 used by NAK | [MIT](LICENSES/switch/runtime/rustc-hash-2.1.1/LICENSE-MIT) or [Apache-2.0](LICENSES/switch/runtime/rustc-hash-2.1.1/LICENSE-APACHE) |
| BLAKE3 C 1.8.2 used by Mesa | [Apache-2.0](LICENSES/switch/runtime/blake3-1.8.2/LICENSE_A2) |

## Fonts and artwork

- PT Serif Regular is embedded for the native overlay under the SIL Open Font License 1.1.
- Supplemental Japanese glyph images were generated from Noto Sans JP, also under the SIL
  Open Font License 1.1.
- The Homebrew Menu icon is original artwork generated specifically for Castlevania-NX;
  it contains no image extracted from the game. Its source PNG and release JPEG are in
  `switch/` under this project's MIT license.

## LGPL components

FFmpeg and libmspack are statically linked. The Switch FFmpeg configuration reports
`CONFIG_GPL=0`, `CONFIG_NONFREE=0` and `CONFIG_VERSION3=0`; its license string is
`LGPL version 2.1 or later`. The Switch overlay enables WMAv2 and disables unavailable
Horizon facilities, without enabling GPL or non-free FFmpeg components.

The release source provides the port changes, SDK changes, configuration and build
instructions needed to regenerate the game translation from the user's supported
`default.xex`, substitute a modified FFmpeg or libmspack, and relink the NRO. No license
term is intended to prohibit reverse engineering needed to debug a user's modification of
an LGPL component. Full details are in [docs/RELINKING.md](docs/RELINKING.md).

## Trademarks and game content

Castlevania and Symphony of the Night are associated with Konami; Xbox is associated with
Microsoft; Nintendo Switch is associated with Nintendo. Their owners do not sponsor or
endorse this project.

No original Xbox Live Arcade package, `default.xex`, or extracted game data is distributed
in the source repository or release assets. Users must provide their own legally obtained
copy.
