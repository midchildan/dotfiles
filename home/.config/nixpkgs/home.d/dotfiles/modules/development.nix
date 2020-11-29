{ config, lib, pkgs, ... }:

with lib;

{
  options.programs.dotfiles.development.enable =
    mkEnableOption "Development packages";

  config = mkIf config.programs.dotfiles.development.enable {
    home.packages = with pkgs; [
      clang-tools
      github-cli
      gopls
      tokei
      universal-ctags
    ];
  };
}
