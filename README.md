# Castlevania-NX

Castlevania-NX is an unofficial Nintendo Switch port of the Xbox Live Arcade
version of **Castlevania: Symphony of the Night**. It is based on
[NocturneRecomp 1.4.5](https://github.com/birabittoh/NocturneRecomp), translates the
game's Xbox 360 PowerPC program to native AArch64 code with ReXGlue, and renders through
Vulkan using Mesa's NVK driver.

Castlevania-NX 1.0.0 is the first public Switch release. It is not an emulator and the
download is not a copy of the game.

> [!IMPORTANT]
> You must provide your own legally obtained Xbox Live Arcade package or extracted game
> files. The supported `default.xex` has SHA-256
> `26a58b074c5dd6185b77a8111a0012866d11cba674b4b0810d79dbf07ad68aa6`.
> No other executable is supported by this release.

## Install

See [docs/INSTALL.md](docs/INSTALL.md) for the complete instructions.

The short version is:

1. Create `sdmc:/switch/castlevania-nx/` and put `castlevania-nx.nro` there.
2. Either put the extracted XBLA files in `sdmc:/switch/castlevania-nx/game/`, or put the
   original LIVE/CON/PIRS package in `sdmc:/switch/castlevania-nx/package/` and let the
   port extract it on first launch.
3. Open the Homebrew Menu by holding **R** while starting an installed title, then launch
   `castlevania-nx.nro`. Album/applet mode does not provide enough memory and is not
   supported.

The installed tree should begin like this:

```text
/switch/castlevania-nx/
  castlevania-nx.nro
  nocturnerecomp.toml       optional release configuration
  game/                     extracted, user-supplied XBLA files
    default.xex
```

The sidecar remains named `nocturnerecomp.toml` because `nocturnerecomp` is the
application's internal project name.

## Current status

Menus, controller input, music, video and normal gameplay were exercised on real hardware.
The hardware validation run held both Host and Guest at 60 FPS in the tested route, with no
observed rendering artifacts. The public-artwork release rebuild keeps the same gameplay
and performance paths.

That result was measured with these clocks:

| Component | Tested clock |
|---|---:|
| CPU | 1963.5 MHz |
| GPU | 998.4 MHz |
| Memory | 2131.2 MHz |

Performance at Nintendo's stock clocks has **not** been characterized, so 60 FPS at stock
clocks is not promised. Overclocking is optional, carries risk, and is the console owner's
decision.

For performance, this release deliberately omits the decorative animated cloud layer
outside the small gameplay viewport. The gameplay image itself remains intact. It also
skips a strictly matched full-screen frontbuffer resolve that is redundant with the native
present path; partial, differently addressed and texture-consumed resolves keep the normal
path.

## Controls

By default, each Switch face button acts as the Xbox 360 button with the same letter, so
**A accepts** and **B goes back**. `+` is Start, `-` is Back, `L/R` are the bumpers and
`ZL/ZR` are the triggers. Set `input_xbox_layout = true` in `nocturnerecomp.toml` to map
the face buttons by physical position instead.

The port also exposes these optional runtime panels:

| Shortcut | Panel |
|---|---|
| `L + R + Up` | Performance/debug overlay |
| `L + R + Right` | Settings |
| `L + R + Down` | Log console |
| `L + R + Left` | Achievements |

## How it works

- ReXGlue statically recompiles the supported `default.xex` to C++, which is compiled for
  AArch64. The generated translation is not stored in this repository.
- NocturneRecomp's in-process native renderer interprets the game's GPU command stream and
  translates Xenos shaders to SPIR-V.
- Mesa/NVK supplies Vulkan on the Switch's NVIDIA GPU.
- The Switch runtime supplies Horizon memory, threads, exception handling, audio and input.
- WMAv2 decoding is enabled for the XBLA music path.

Technical build and licensing details are in:

- [docs/BUILDING.md](docs/BUILDING.md)
- [docs/RELINKING.md](docs/RELINKING.md)
- [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)
- [NOTICE](NOTICE) and [LICENSES](LICENSES) — licence texts shipped in the release ZIP

## Credits

- [NocturneRecomp](https://github.com/birabittoh/NocturneRecomp) by Marco Andronaco and
  contributors.
- [ReXGlue SDK](https://github.com/rexglue/rexglue-sdk) by Tom Clay, incorporating work from
  the [Xenia](https://xenia.jp) project and its contributors.
- [project8-sw](https://github.com/R-drg/project8-sw) by R-drg and
  [nfsmw-nx](https://github.com/StevensND/nfsmw-nx) by StevensND, whose documented Horizon,
  renderer and Mesa work made this port possible.
- [mesa-switch](https://github.com/danfromtico/mesa-switch) by danfromtico and NaGaa95,
  the Mesa/NVK/NAK developers, devkitPro, libnx and switchbrew.
- Every project and library listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Legal

This is an unofficial fan project. It is not affiliated with or endorsed by Konami,
Nintendo or Microsoft. Castlevania, Symphony of the Night, Xbox and Nintendo Switch names
and marks belong to their respective owners.

The release does not contain the original `default.xex`, XBLA package, music, video or game
data. The NRO is a static recompilation and will not run without the user's matching,
legally obtained files. Running homebrew and changing console clocks may violate platform
terms or create hardware/data risks; users are responsible for their own systems.
