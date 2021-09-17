{ pkgs ? import <nixpkgs> { }
, mkShellNoCC ? pkgs.mkShellNoCC
, nixUnstable ? pkgs.nixUnstable
, curl ? pkgs.curl
, git ? pkgs.git
, neovim ? pkgs.neovim
}:

mkShellNoCC {
  nativeBuildInputs = [ nixUnstable curl git neovim ];
}
