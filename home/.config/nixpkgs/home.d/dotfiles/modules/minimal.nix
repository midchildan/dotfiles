{ config, lib, pkgs, ... }:

with lib;

let
  isGenericLinux = (config.targets.genericLinux.enable or false);
  extraPkgs = import ../pkgs { inherit pkgs; };
in {
  options.profiles.minimal.enable = mkOption {
    type = types.bool;
    default = true;
    description = "The bare minimum packages to make the dotfiles useful";
  };

  config = mkIf config.profiles.minimal.enable {
    home.packages = with pkgs;
      [ direnv fzf less ripgrep zsh-syntax-highlighting ]
      ++ (with pkgs.vimPlugins; [ coc-nvim coc-snippets ])
      ++ optional isGenericLinux extraPkgs.nixpath
      ++ optional (isGenericLinux || isDarwin) nix-zsh-completions;

    programs.neovim = {
      enable = true;
      withNodeJs = true;
    };
  };
}
