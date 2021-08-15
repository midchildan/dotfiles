{ pkgs ? import <nixpkgs> { } }:

let
  # for home/.config/nixpkgs/home.d/dotfiles/pkgs/cloudfoundry-cli-6/get-latest-tag.py
  python = pkgs.python3.withPackages (ps: with ps; [
    requests
    semver
    yapf
  ]);
in
pkgs.mkShellNoCC {
  nativeBuildInputs = with pkgs; [
    nixpkgs-fmt
    python
    shellcheck
  ];
}
