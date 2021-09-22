{ mkShellNoCC
, curl-h3
, quictls
}:

mkShellNoCC {
  nativeBuildInputs = [
    curl-h3
    quictls
  ];
}
