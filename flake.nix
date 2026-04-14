{
  description = "A collection of compatibility tools and other gaming related things";

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
      };
    in
    {
      packages.${system} = {
        dw-proton-bin = pkgs.callPackage ./pkgs/dw-proton-bin/package.nix { };
        default = self.packages.${system}.dw-proton-bin;
      };
    };
}
