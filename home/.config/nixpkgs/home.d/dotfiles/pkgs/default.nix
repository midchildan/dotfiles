{ pkgs ? import <nixpkgs> { } }:

{
  nixpath = pkgs.callPackage ./nixpath.nix { };
  bpftrace = pkgs.callPackage ./bpftrace.nix { };
  cloudfoundry-cli-6 = pkgs.callPackage ./cloudfoundry-cli-6 { };
  neovim = pkgs.callPackage ./neovim.nix { };
  pinentry_mac = pkgs.callPackage ./pinentry-mac.nix { };
  terminfo-collection = pkgs.callPackage ./terminfo-collection.nix { };
  zsh = pkgs.callPackage ./zsh.nix { };
}
