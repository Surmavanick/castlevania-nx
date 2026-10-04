# Relinking FFmpeg and libmspack

Castlevania-NX 1.0.0 statically links two LGPL libraries through ReXGlue:

- FFmpeg `libavcodec` and `libavutil`, LGPL-2.1-or-later.
- libmspack, LGPL-2.1.

Because they are static libraries in a Switch NRO rather than replaceable shared objects,
the relinking and corresponding-source provisions of LGPL 2.1 are relevant. This document
records exactly what was used and how a recipient can rebuild with modified versions.

## FFmpeg configuration

| Item | Value |
|---|---|
| Fork | `https://github.com/wmarti/FFmpeg.git` |
| Commit | `0604b464c7cb4ebc94940cf1f324a3b26b87717c` |
| Linked components | `libavcodec`, `libavutil` |
| License reported by config | `LGPL version 2.1 or later` |
| `CONFIG_GPL` | `0` |
| `CONFIG_NONFREE` | `0` |
| `CONFIG_VERSION3` | `0` |

The ReXGlue Switch build uses a Horizon configuration overlay based on the fork's
Linux/AArch64 configuration. The overlay enables the WMAv2 decoder required by the XBLA
music, disables facilities Horizon does not provide, and does not enable GPL or non-free
FFmpeg components. The overlay and CMake changes are part of the published ReXGlue patch
set, so they are corresponding source for the linked build.

## libmspack source

| Item | Value |
|---|---|
| Upstream source | ReXGlue's `thirdparty/libmspack` submodule |
| Commit | `305907723a4e7ab2018e58040059ffb5e77db837` |
| License | LGPL-2.1 |

The release build uses the submodule at that revision. Any Castlevania-NX changes affecting
how it is compiled or linked are published with the ReXGlue source changes.

## Rebuild with a modified library

1. Obtain the source tag corresponding to the NRO and initialize the ReXGlue submodules.
2. Regenerate the guest translation from your own supported `default.xex`, following
   [BUILDING.md](BUILDING.md). Generated game translation units are intentionally not
   redistributed.
3. Replace or modify `thirdparty/FFmpeg` and/or `thirdparty/libmspack` in the ReXGlue source
   tree. Keep the public APIs expected by ReXGlue, and choose licensing options compatible
   with the combined work.
4. Reconfigure the Switch build so CMake recompiles the changed static library.
5. Rebuild `nocturnerecomp.nro` with the exact CMake path in
   [BUILDING.md](BUILDING.md). The final static link incorporates the replacement library.

The application sources, ReXGlue changes, Mesa changes, build configuration and tools needed
for that rebuild are published as source. The only omitted build input is the copyrighted
game executable and the generated translation derived from it; a user who owns the supported
game can regenerate that translation locally.

Recipients may reverse engineer the NRO as needed to debug modifications to the LGPL
libraries. Castlevania-NX imposes no additional restriction intended to prevent that work.

If the published source or instructions are insufficient to exercise these rights, open an
issue at <https://github.com/Surmavanick/castlevania-nx/issues> and identify the missing
material.

## Resulting license choices

The shipped FFmpeg configuration contains neither GPL nor non-free components. Enabling a
different FFmpeg component can change the license obligations or make a combined binary
non-redistributable. Review FFmpeg's `LICENSE.md` and the license text for every component
you enable before distributing a modified NRO.

This document describes the release's source and build process; it is not legal advice.
