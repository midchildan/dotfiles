{ pkgs ? import <nixpkgs> { } }:

{
  nixpath = pkgs.callPackage ./nixpath.nix { };
  bpftrace = pkgs.callPackage ./bpftrace.nix { };
}
