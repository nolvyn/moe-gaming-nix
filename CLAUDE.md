# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Nix flake providing gaming compatibility tools — `dw-proton-bin` (Dawn Winery's custom Proton fork, geared toward making gacha games run on Linux) and `proton-cachyos-bin` (CachyOS's general-purpose, performance-oriented Proton fork, in the vein of GE-Proton but more modern). The two are complementary: DW-Proton is the go-to for gacha titles, while Proton-CachyOS is a strong general/performance option and a useful fallback when DW-Proton hasn't yet been updated for a breaking game patch. Exposes packages, an overlay, and a NixOS module.

## Common commands

```bash
# Build the packages
nix build .#dw-proton-bin
nix build .#proton-cachyos-bin

# Validate the flake (checks outputs are well-formed)
nix flake check

# Update flake inputs
nix flake update

# Manually update dw-proton-bin to a specific version (mirrors what CI does)
nix run nixpkgs#nix-update -- --flake dw-proton-bin --version-regex 'dwproton-(.+)' --version <VERSION>

# Manually update proton-cachyos-bin to a specific version (mirrors what CI does)
nix run nixpkgs#nix-update -- --flake proton-cachyos-bin --version-regex 'cachyos-(.+)' --version <VERSION>
```

## Architecture

**`flake.nix`** — Single input (`nixpkgs` unstable). Outputs: `overlays.default` (adds `dw-proton-bin` and `proton-cachyos-bin` via callPackage), `packages.x86_64-linux.{dw-proton-bin,proton-cachyos-bin}`, and `nixosModules.{default,moe-gaming}` (both point to the same module).

**`pkgs/dw-proton-bin/package.nix`** — Binary-only package (`stdenvNoCC`, skips unpack/configure/build phases). Produces two outputs:
- `out` — intentionally a stub file with an error message; this package is not meant to be installed into environments directly.
- `steamcompattool` — the actual compatibility tool directory, symlinked from the source, with `compatibilitytool.vdf` copied (not symlinked) so it can be patched with `substituteInPlace` to set the display name.

**`pkgs/proton-cachyos-bin/package.nix`** — Same shape and two-output (`out`/`steamcompattool`) pattern as `dw-proton-bin`. Fetches from the CachyOS GitHub releases. Tags are `cachyos-<version>` (e.g. `cachyos-11.0-20260602-slr`) and assets are `proton-cachyos-<version>-<cpuVariant>.tar.xz`. The `cpuVariant` arg (default `x86_64_v3`, optimized for AVX2/BMI2/FMA CPUs; `x86_64` is the portable baseline) selects which build to pull; it's part of both the asset name and the internal vdf tool name, so the `substituteInPlace` display-name patch keys off `proton-cachyos-<version>-<cpuVariant>`.

**`modules/nixos/default.nix`** — Three options: `moe-gaming.dw-proton-bin.enable`, `moe-gaming.proton-cachyos-bin.enable`, and `moe-gaming.proton.enable` (an aggregate that just sets the other two to `true`). Config is a `lib.mkMerge` of one `mkIf` block per option. When a tool is enabled, it's added to `programs.steam.extraCompatPackages` and a systemd `tmpfiles` symlink is created at `~/.local/share/Steam/compatibilitytools.d/<tool>` pointing to its `steamcompattool` output. The symlink covers Heroic and Lutris as well as Steam.

**`.github/workflows/update-dw-proton-bin.yaml`** — Runs daily, fetches the latest non-prerelease tag from the Gitea API at `dawn.wine`, runs `nix-update`, and commits the bump directly to `main`.

**`.github/workflows/update-proton-cachyos-bin.yaml`** — Runs daily, fetches the latest stable tag from GitHub's `/releases/latest` endpoint (strips the `cachyos-` prefix), runs `nix-update`, and commits the bump directly to `main`.

## Adding a new package

1. Create `pkgs/<name>/package.nix`.
2. Add it to the overlay in `flake.nix` via `prev.callPackage`.
3. Expose it under `packages.${system}`.
4. Optionally add a NixOS module under `modules/nixos/` and wire it into `nixosModules` in `flake.nix`.
