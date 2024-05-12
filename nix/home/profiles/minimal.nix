{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkIf
    mkOption
    optional
    types
    ;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin system;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  isNixOS = isLinux && !isGenericLinux;
  myPkgs = dotfiles.packages.${system};
in
{
  options.dotfiles.profiles.minimal.enable = mkOption {
    type = types.bool;
    default = true;
    description = ''
      Whether to enable the bare minimum packages to make the dotfiles useful
    '';
  };

  config = mkIf config.dotfiles.profiles.minimal.enable {
    home.packages = with pkgs; [
      fzf
      less
      ripgrep
      zsh-syntax-highlighting
      myPkgs.neovim
    ];

    programs.direnv = {
      enable = mkDefault true;
      nix-direnv.enable = mkDefault true;
    };

    dotfiles.manpages = {
      enable = mkDefault true;
      useSystemMan = mkDefault (!isNixOS);
    };

    dotfiles.vim.plugins.start = with pkgs.vimPlugins; [
      fzfWrapper
      coc-nvim
      coc-snippets
      coc-json
    ];
  };
}
