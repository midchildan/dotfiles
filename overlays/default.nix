{ inputs }:

final: prev:

# Forward to the right overlay by comparing releases

let
  inherit (inputs) self nixpkgs nixos;

  # NOTE: this doesn't compare individual commits, only releases
  isSameRelease = pkgs: flake:
    pkgs.lib.trivial.release == flake.lib.trivial.release;

  overlay =
    if isSameRelease prev nixpkgs then import ./nixpkgs.nix
    else if isSameRelease prev nixos then import ./nixos.nix
    else final: prev: { };
in
overlay final prev
