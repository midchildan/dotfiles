{ wrapNeovim, neovim-unwrapped }:

wrapNeovim neovim-unwrapped { withNodeJs = true; }
