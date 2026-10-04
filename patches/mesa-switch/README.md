# Mesa/NVK patches

The release links NVK/NAK built from
[danfromtico/mesa-switch](https://github.com/danfromtico/mesa-switch) at commit
`d4a00ea0ab3f59afb967cc5d779e4263d237bd77` (Mesa 26.2.3), with the four
patches in this directory applied in filename order.

```sh
git clone https://github.com/danfromtico/mesa-switch.git mesa
git -C mesa checkout --detach d4a00ea0ab3f59afb967cc5d779e4263d237bd77
for patch in "$PWD"/patches/mesa-switch/000*.patch; do
  git -C mesa apply "$patch"
done
(cd mesa && ./build-switch-p8.sh)
tools/switch/stage-nvk.sh mesa nvk-sdk
```

Mesa's build creates the merged `libvulkan.a`; `stage-nvk.sh` checks that both outputs
exist, requires a clean destination, copies the public Vulkan headers and both archives,
then rebuilds the merged Vulkan archive's index with devkitA64. Compare the printed hashes
with these expected staged inputs for v1.0.0:

| File | Bytes | SHA-256 |
|---|---:|---|
| `nvk-sdk/lib/libvulkan.a` | 93,922,796 | `4904226fb506ac1ef95dc5eb80064f93d2e6153224d6c458dbf04f1cd2ed9131` |
| `nvk-sdk/lib/libnak_rs.a` | 33,761,108 | `b663c4f8b3f6584b9de24f8a6c7094dd37e745d4bc6d6dc79ec969def66c5074` |

These are the MIT-licensed Mesa patches published by project8-sw. Patch 0002 incorporates
MIT-licensed pre-Volta NAK work from nfsmw-nx. See the
[third-party notices](../../THIRD_PARTY_NOTICES.md) and [full licence bundle](../../NOTICE).

The patched Mesa helper uses rolling package repositories and Rust nightly, so the pinned
source revisions make this source-reproducible, not guaranteed byte-for-byte reproducible.
