{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

  outputs = {nixpkgs, ... }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in 
  {
    packages.x86_64-linux = rec {
      openscad = pkgs.libsForQt5.callPackage ./openscad.nix {};
      default = openscad;
    };
  };
}
