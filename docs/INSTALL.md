# Installing Castlevania-NX

## Requirements

- A Nintendo Switch capable of running homebrew with full application memory.
- The `castlevania-nx.nro` release asset.
- Your own legally obtained Xbox Live Arcade package, or files extracted from it.

This release supports one vanilla XBLA executable:

```text
default.xex SHA-256
26a58b074c5dd6185b77a8111a0012866d11cba674b4b0810d79dbf07ad68aa6
```

The current NRO is not a Title Update build. A different executable, region/revision or
pre-patched XEX is not supported merely because it has the same filename.

## 1. Create the application folder

Copy the release files to:

```text
sdmc:/switch/castlevania-nx/
  castlevania-nx.nro
  nocturnerecomp.toml       recommended, but optional
```

The config filename is intentionally `nocturnerecomp.toml`; changing it prevents the
application from finding the sidecar automatically.

## 2. Supply the game

Choose one of the following methods.

### Extracted files

Put the contents of the XBLA package in `game/` next to the NRO. `default.xex`, `DATA`,
`MEDIA` and the other package files must keep their original layout.

```text
sdmc:/switch/castlevania-nx/
  castlevania-nx.nro
  game/
    default.xex
    DATA/
    MEDIA/
    ...
```

### Original XBLA package

Alternatively, create `package/` next to the NRO and place the original LIVE/CON/PIRS file
inside it:

```text
sdmc:/switch/castlevania-nx/
  castlevania-nx.nro
  package/
    your-owned-xbla-package
```

On first launch, Castlevania-NX detects the STFS package, extracts it into `game/`, and
validates `game/default.xex`. Extraction can take time; do not close the application or
remove the SD card while it is writing.

The game files never need to be uploaded to this project's maintainers or to GitHub.

## 3. Launch with full memory

1. Hold **R** while starting an installed Switch title.
2. Keep holding **R** until the full-memory Homebrew Menu opens.
3. Start `castlevania-nx.nro`.

Do not launch it from Album applet mode. Applet mode has substantially less memory and is
not supported. A forwarder must likewise provide a full application address space.

## Configuration paths

libnx exposes the SD card as the POSIX root to this application. Paths inside
`nocturnerecomp.toml` therefore use `/switch/...`, not `sdmc:/switch/...`.

The supplied configuration uses:

```text
/switch/castlevania-nx/game
/switch/castlevania-nx/nocturnerecomp
/switch/castlevania-nx/nocturnerecomp/cache
/switch/castlevania-nx/mods
```

The application creates its user data, cache and logs as needed. Preserve the
`nocturnerecomp/`, `game/` and `mods/` directories when updating.

## Updating

Replace `castlevania-nx.nro` with the newer release asset. Keep your game and user-data
directories. If a release includes a revised `nocturnerecomp.toml`, compare it with your
copy before replacing settings you changed.

## Performance expectations

The release was validated at 60 Host FPS and 60 Guest FPS on the tested route with CPU
1963.5 MHz, GPU 998.4 MHz and memory 2131.2 MHz. Stock-clock performance has not been
measured. This is a test result, not a promise that every scene, console or clock profile
will hold 60 FPS.

The decorative cloud animation outside the gameplay viewport is intentionally disabled to
save GPU work. No gameplay-area rendering artifacts were observed during the validation
run.

Overclock only if you understand the risks. Unstable clocks can crash software or corrupt
data; the project does not require or automatically configure the tested overclock values.

## Troubleshooting

- **The port says game files are required:** verify the folder names above and check the
  SHA-256 of `game/default.xex`.
- **It exits or fails from Album:** use R-held title takeover.
- **A first launch appears slow:** package extraction and first-use graphics work can take
  longer than later starts.
- **Unexpected corruption appears around a transition or menu:** set
  `switch_skip_redundant_frontbuffer_resolve = false` in `nocturnerecomp.toml` and retry.
  This restores the complete frontbuffer resolve path.
- **A report is needed:** attach the application and `logs/rex/` logs, but never attach the
  XBLA package, `default.xex`, saves or extracted game assets.

Optional developer panels use `L + R + D-pad`: Up opens performance/debug, Right opens
settings, Down opens the log console and Left opens achievements.
