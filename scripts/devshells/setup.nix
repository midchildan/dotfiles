{ mkShellNoCC
, nixUnstable
, curl
, git
, neovim
}:

mkShellNoCC {
  nativeBuildInputs = [
    nixUnstable
    curl
    git
    neovim
  ];
}
