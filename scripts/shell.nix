{ pkgs ? import <nixpkgs> { } }:

let
  # for packages.cloudfoundry-cli-6.updateScript
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
