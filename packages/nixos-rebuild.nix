{ nixos-rebuild, nixUnstable }:

nixos-rebuild.override { nix = nixUnstable; }
