{ config, lib, pkgs, ... }:

with lib;

{
  options.profiles.development.enable = mkEnableOption "Development packages";

  config = mkIf config.profiles.development.enable {
    home.packages = with pkgs;
      [ clang-tools github-cli gopls tokei universal-ctags ];
  };
}
