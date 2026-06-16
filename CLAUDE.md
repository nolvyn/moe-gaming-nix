# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Nix flake providing gaming compatibility tools — currently just `dw-proton-bin` (Dawn Winery's custom Proton fork). Exposes a package, an overlay, and a NixOS module.

## Common commands

```bash
# Build the package
nix build .#dw-proton-bin

# Validate the flake (checks outputs are well-formed)
nix flake check

# Update flake inputs
nix flake update

# Manually update dw-proton-bin to a specific version (mirrors what CI does)
nix run nixpkgs#nix-update -- --flake dw-proton-bin --version-regex 'dwproton-(.+)' --version <VERSION>
```

## Architecture

**`flake.nix`** — Single input (`nixpkgs` unstable). Outputs: `overlays.default` (adds `dw-proton-bin` via callPackage), `packages.x86_64-linux.dw-proton-bin`, and `nixosModules.{default,moe-gaming}` (both point to the same module).

**`pkgs/dw-proton-bin/package.nix`** — Binary-only package (`stdenvNoCC`, skips unpack/configure/build phases). Produces two outputs:
- `out` — intentionally a stub file with an error message; this package is not meant to be installed into environments directly.
- `steamcompattool` — the actual compatibility tool directory, symlinked from the source, with `compatibilitytool.vdf` copied (not symlinked) so it can be patched with `substituteInPlace` to set the display name.

**`modules/nixos/default.nix`** — Single option: `moe-gaming.dw-proton-bin.enable`. When enabled, adds the package to `programs.steam.extraCompatPackages` and creates a systemd `tmpfiles` symlink at `~/.local/share/Steam/compatibilitytools.d/dw-proton-bin` pointing to the `steamcompattool` output. The symlink covers Heroic and Lutris as well as Steam.

**`.github/workflows/update-dw-proton-bin.yaml`** — Runs daily, fetches the latest non-prerelease tag from the Gitea API at `dawn.wine`, then runs `nix-update` and opens a PR via `peter-evans/create-pull-request`.

## Adding a new package

1. Create `pkgs/<name>/package.nix`.
2. Add it to the overlay in `flake.nix` via `prev.callPackage`.
3. Expose it under `packages.${system}`.
4. Optionally add a NixOS module under `modules/nixos/` and wire it into `nixosModules` in `flake.nix`.
