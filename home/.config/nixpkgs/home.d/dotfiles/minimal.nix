{ config, pkgs, ... }:

{

  options.programs.dotfiles.minimal.enable =
    mkOption {
      type = types.bool;
      default = true;
      description = "The bare minimal packages to make the dotfiles useful";
    };

  config = mkIf config.programs.dotfiles.minimal.enable {
    home.packages = with pkgs;
      [ direnv fzf ripgrep zsh-syntax-highlighting ]
      ++ (with pkgs.vimPlugins; [ coc-nvim coc-snippets ]);

    programs.neovim = {
      enable = true;
      withNodeJs = true;
    };
  };
}
