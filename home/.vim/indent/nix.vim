if executable('nixpkgs-fmt')
  setlocal formatprg=nixpkgs-fmt
elseif executable('nixfmt')
  setlocal formatprg=nixfmt
endif
