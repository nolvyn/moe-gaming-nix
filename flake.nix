{
  description = "A collection of modules and other gaming compatibility tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };
    in
    {
      overlays.default = final: prev: {
        dw-proton-bin = prev.callPackage ./pkgs/dw-proton-bin/package.nix { };
      };

      packages.${system} = {
        dw-proton-bin = pkgs.dw-proton-bin;
        default = pkgs.dw-proton-bin;
      };

      nixosModules = {
        default = ./modules/nixos/default.nix;
        moe-gaming = ./modules/nixos/default.nix;
      };
    };
}
