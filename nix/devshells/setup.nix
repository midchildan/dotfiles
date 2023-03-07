{ mkShellNoCC
, nix
, curl
, git
, neovim
}:

mkShellNoCC {
  nativeBuildInputs = [
    nix
    curl
    git
    neovim
  ];
}
