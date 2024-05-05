{
  mkShellNoCC,
  curlHTTP3,
  quictls,
}:

mkShellNoCC {
  nativeBuildInputs = [
    curlHTTP3
    quictls
  ];
}
