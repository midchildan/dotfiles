{
  mkShellNoCC,
  nix,
  curl,
  emacs-nox,
  git,
  neovim,
}:

mkShellNoCC {
  nativeBuildInputs = [
    nix
    curl
    emacs-nox
    git
    neovim
  ];
}
