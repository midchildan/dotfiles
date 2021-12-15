{ nixos-rebuild, nix }:

nixos-rebuild.override { inherit nix; }
