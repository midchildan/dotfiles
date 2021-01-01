{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  isNixOS = isLinux && !isGenericLinux;
  extraPkgs = import ../pkgs { inherit pkgs; };
in {
  options.dotfiles.profiles.minimal.enable = mkOption {
    type = types.bool;
    default = true;
    description = "The bare minimum packages to make the dotfiles useful";
  };

  config = mkIf config.dotfiles.profiles.minimal.enable {
    home.packages = with pkgs;
      [ fzf less ripgrep zsh-syntax-highlighting ]
      ++ (with pkgs.vimPlugins; [ coc-nvim coc-snippets coc-json ])
      ++ optional isGenericLinux extraPkgs.nixpath
      ++ optional (isGenericLinux || isDarwin) nix-zsh-completions;

    programs.direnv = {
      enable = mkDefault true;
      enableNixDirenvIntegration = mkDefault true;
    };

    programs.neovim = {
      enable = true;
      withNodeJs = true;
    };

    # HACK: prevent HM from dropping its own Neovim config
    xdg.configFile."nvim/init.vim".target =
      "${config.xdg.dataHome}/home-manager/diverted/init.vim";

    dotfiles.manpages.enable = mkDefault (!isNixOS);
  };
}
