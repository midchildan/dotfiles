# provides the bare minimum required for this dotfiles to function well

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cmigemo
    direnv
    fzf
    ripgrep
    zsh-syntax-highlighting

    # consider removing this and installing this system-wide instead
    emacs-all-the-icons-fonts
  ] ++ (with pkgs.vimPlugins; [
    coc-nvim
    coc-snippets
  ]);

  programs.neovim = {
    enable = true;
    withNodeJs = true;
  };
}
