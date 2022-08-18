{ mkShellNoCC
, formatter
, shellcheck
}:

mkShellNoCC {
  nativeBuildInputs = [
    formatter
    shellcheck
  ];
}
