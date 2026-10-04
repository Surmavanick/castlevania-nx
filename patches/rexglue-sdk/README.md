# ReXGlue SDK patch

The Switch build uses [birabittoh/rexglue-sdk](https://github.com/birabittoh/rexglue-sdk)
at commit `7766f97126a40399d76105d431ae37c802eba740` (`origin/sotn`) plus the patch
listed in `series`.

```sh
git clone --recursive https://github.com/birabittoh/rexglue-sdk.git
git -C rexglue-sdk checkout 7766f97126a40399d76105d431ae37c802eba740
git -C rexglue-sdk submodule update --init --recursive
git -C rexglue-sdk am ../castlevania-nx/patches/rexglue-sdk/0001-switch-horizon-runtime-and-sotn-compatibility.patch
```

The patch contains the Horizon runtime and the final SotN compatibility, audio, shader,
input and profiling fixes used by the release. It includes no generated game code.

Patch SHA-256:

```text
6ca881e1c542e4477082e419f1f1d63a24f7cc0290ae3ceaa2a860e2a6d29632
```

The SDK and the changes in this directory retain the SDK's BSD-3-Clause license and Xenia
attribution. The exact FFmpeg and libmspack submodules and their LGPL terms are documented
in [the relinking guide](../../docs/RELINKING.md).
