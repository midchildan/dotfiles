{ mkShellNoCC
, nixpkgs-fmt
, shellcheck
}:

mkShellNoCC {
  nativeBuildInputs = [
    nixpkgs-fmt
    shellcheck
  ];
}
