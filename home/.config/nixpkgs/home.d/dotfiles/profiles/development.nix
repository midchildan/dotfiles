{ config, lib, pkgs, ... }:

with lib;

let inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  options.dotfiles.profiles.development.enable =
    mkEnableOption "Development packages";

  config = mkIf config.dotfiles.profiles.development.enable {
    home.packages = with pkgs;
      [ clang-tools github-cli gopls tokei universal-ctags ]
      ++ optional isDarwin gnupg;

    dotfiles.pinentry-mac.enable = mkDefault isDarwin;
  };
}
