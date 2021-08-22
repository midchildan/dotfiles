{ config, lib, pkgs, dotfiles, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin system;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  isNixOS = isLinux && !isGenericLinux;
  myPkgs = dotfiles.packages.${system};
in {
  options.dotfiles.profiles.minimal.enable = mkOption {
    type = types.bool;
    default = true;
    description = ''
      Whether to enable the bare minimum packages to make the dotfiles useful
    '';
  };

  config = mkIf config.dotfiles.profiles.minimal.enable {
    home.packages = with pkgs;
      [ fzf less ripgrep zsh-syntax-highlighting myPkgs.neovim ]
      ++ (with pkgs.vimPlugins; [ coc-nvim coc-snippets coc-json ])
      ++ optional isGenericLinux myPkgs.nixpath;

    programs.direnv = {
      enable = mkDefault true;
      nix-direnv = {
        enable = mkDefault true;
        enableFlakes = mkDefault true;
      };
    };

    dotfiles.manpages = {
      enable = mkDefault true;
      useSystemMan = mkDefault (!isNixOS);
    };
  };
}
