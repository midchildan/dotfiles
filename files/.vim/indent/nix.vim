" Standard Nix formatting rules are defined in
" https://github.com/NixOS/rfcs/blob/master/rfcs/0166-nix-formatting.md

setlocal colorcolumn=101

if executable('nixfmt')
  setlocal formatprg=nixfmt
elseif executable('nixpkgs-fmt')
  setlocal formatprg=nixpkgs-fmt
endif
