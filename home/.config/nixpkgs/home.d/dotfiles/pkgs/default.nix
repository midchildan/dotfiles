{ pkgs ? import <nixpkgs> { } }:

{
  nixpath = pkgs.callPackage ./nixpath.nix { };
  bpftrace = pkgs.callPackage ./bpftrace.nix { };
  fira-code = pkgs.callPackage ./fira-code.nix { };
  neovim = pkgs.callPackage ./neovim.nix { };
  pinentry_mac = pkgs.callPackage ./pinentry-mac.nix { };
  powerline-symbols = pkgs.callPackage ./powerline-symbols.nix { };
  terminfo-collection = pkgs.callPackage ./terminfo-collection.nix { };
  zsh = pkgs.callPackage ./zsh.nix { };
}
