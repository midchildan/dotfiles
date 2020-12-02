{ pkgs ? import <nixpkgs> { } }:

{
  nixpath = pkgs.callPackage ./nixpath.nix { };
  bpftrace = pkgs.callPackage ./bpftrace.nix { };
  pinentry_mac = pkgs.callPackage ./pinentry-mac.nix { };
}
