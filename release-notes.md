# Castlevania-NX v1.0.0

First public Nintendo Switch release of the Xbox Live Arcade version of
**Castlevania: Symphony of the Night**, based on NocturneRecomp 1.4.5.

## Install

The ZIP is the recommended download because it includes the NRO, optional configuration,
shader, instructions and complete license bundle. The raw NRO is also attached for
convenience.

1. Create `sdmc:/switch/castlevania-nx/` and copy `castlevania-nx.nro` there.
2. Put your legally obtained extracted XBLA files in
   `sdmc:/switch/castlevania-nx/game/`, or put the original LIVE/CON/PIRS package in
   `sdmc:/switch/castlevania-nx/package/` for first-run extraction.
3. Launch through the full-memory Homebrew Menu: hold **R** while starting an installed
   title, then select Castlevania-NX. Album/applet mode is not supported.

Supported `default.xex` SHA-256:

```text
26a58b074c5dd6185b77a8111a0012866d11cba674b4b0810d79dbf07ad68aa6
```

The NRO does not work by itself. It contains neither the original `default.xex` nor the
game's data, music or video files.

## What works

- Menus and normal gameplay.
- Switch controller input.
- WMAv2 game music and video playback.
- Native Vulkan rendering through Mesa/NVK.
- Automatic discovery of extracted `game/` data and first-run extraction from `package/`.

No rendering artifacts were observed during the final validation run.

## Performance

The hardware validation build held Host and Guest at 60 FPS in the tested route. The
public-artwork release rebuild keeps the same gameplay and performance paths. Testing used:

- CPU: 1963.5 MHz
- GPU: 998.4 MHz
- Memory: 2131.2 MHz

Stock-clock performance has not been measured, and 60 FPS at stock clocks is not claimed.
Different scenes and systems may behave differently. Overclocking is optional and at the
owner's risk.

This release intentionally disables the decorative animated cloud layer outside the
gameplay viewport. It also skips only the exact full-screen swap-frontbuffer resolve already
made redundant by the native presentation path. Other resolves retain the complete path.

## Major Switch work

- Horizon memory, thread, exception, input, audio and presentation integration.
- Native device-local presentation with the fence wait deferred to safe resource reuse.
- Persistent queued upload for the live 512x256 gameplay-preview texture.
- Faster 32-bit tiled resolve conversion and a guarded redundant-frontbuffer resolve skip.
- WMAv2 decoder registration and Switch stereo downmix/output handling.
- Mapped read-only guest pages for the native renderer, removing the measured hot read-fault
  loop.
- Switch-only stubs for unsupported auto-update, network/Discord and process-relaunch paths.

## Known limitations

- Only the exact vanilla XBLA executable identified above is validated. This is not a Title
  Update build.
- Album/applet mode is unsupported.
- Stock-clock, docked-mode and other Switch-model performance has not been characterized.
- The decorative outer cloud animation is intentionally absent.
- Online, Discord presence and self-update features are unavailable on Switch.
- First-run extraction and first-use graphics work may take longer than subsequent starts.

## Integrity

`castlevania-nx.nro`

```text
Size:     51,516,752 bytes
SHA-256: c9b543428c95d94bbf7f583e08d7e32a257dcc8e9267e7eb2188c34e2fd98243
```

`castlevania-nx-v1.0.0.zip`

```text
Size:     17,945,521 bytes
SHA-256: 7f044b8cde0edb7c5b5acc8db3ac58800ad0551b275b04c86e6148fd5b2f3e6b
```

`castlevania-nx-v1.0.0-licenses.zip`

```text
Size:     169,618 bytes
SHA-256: 11a603d96af93a0e9bf7de68038d0f9e0fbb2bb07c600c2250dc5caca9384de1
```

## Credits and legal

Built from [NocturneRecomp](https://github.com/birabittoh/NocturneRecomp) with
[ReXGlue](https://github.com/rexglue/rexglue-sdk), using work and documentation from
[project8-sw](https://github.com/R-drg/project8-sw),
[nfsmw-nx](https://github.com/StevensND/nfsmw-nx),
[mesa-switch](https://github.com/danfromtico/mesa-switch), Mesa/NVK/NAK, devkitPro, libnx,
Xenia and their contributors. See the
[third-party notices](https://github.com/Surmavanick/castlevania-nx/blob/castlevania-nx-v1.0.0/THIRD_PARTY_NOTICES.md)
and [LGPL relinking instructions](https://github.com/Surmavanick/castlevania-nx/blob/castlevania-nx-v1.0.0/docs/RELINKING.md).

This is an unofficial fan project, not affiliated with or endorsed by Konami, Nintendo or
Microsoft. Users must supply their own legally obtained game. Do not upload game packages,
`default.xex` or extracted assets when reporting an issue.
