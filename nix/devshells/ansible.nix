{ mkShellNoCC
, ansible
, ansible-lint
, python3Packages
}:

mkShellNoCC {
  name = "ansible";
  nativeBuildInputs = [
    ansible
    ansible-lint
    python3Packages.jmespath
  ];
}
