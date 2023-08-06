{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = inputs@{self, nixpkgs, ... }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in 
  {
    packages.x86_64-linux = {
      openscad = pkgs.libsForQt5.callPackage ./openscad.nix {};
    };
  };
}
