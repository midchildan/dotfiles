{
  mkShellNoCC,
  nix,
  curl,
  emacs-nox,
  git,
}:

mkShellNoCC {
  nativeBuildInputs = [
    nix
    curl
    emacs-nox
    git
  ];
}
