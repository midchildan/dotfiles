{ config, lib, pkgs, ... }:

with lib;

{
  options.programs.dotfiles.minimal.enable = mkOption {
    type = types.bool;
    default = true;
    description = "The bare minimum packages to make the dotfiles useful";
  };

  config = mkIf config.programs.dotfiles.minimal.enable {
    home.packages = let nixpath = pkgs.callPackage ../pkgs/nixpath.nix { };
    in (with pkgs; [ direnv fzf ripgrep zsh-syntax-highlighting ])
    ++ (with pkgs.vimPlugins; [ coc-nvim coc-snippets ])
    ++ optional config.targets.genericLinux.enable nixpath;

    programs.neovim = {
      enable = true;
      withNodeJs = true;
    };
  };
}
