{ mkShellNoCC
, nixpkgs-fmt
, python3
, shellcheck
}:

let
  # for packages.cloudfoundry-cli-6.updateScript
  python = python3.withPackages (ps: with ps; [
    requests
    semver
    yapf
  ]);
in
mkShellNoCC {
  nativeBuildInputs = [
    nixpkgs-fmt
    python
    shellcheck
  ];
}
