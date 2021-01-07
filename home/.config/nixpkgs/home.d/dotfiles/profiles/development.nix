{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  cfg = config.dotfiles.profiles;
in {
  options.dotfiles.profiles.development.enable =
    mkEnableOption "development packages";

  config = mkIf cfg.development.enable {
    home.packages = with pkgs;
      [ cargo clang-tools github-cli go gopls shellcheck tokei universal-ctags ]
      ++ (with pkgs.vimPlugins; [ coc-go coc-rust-analyzer coc-tsserver ])
      ++ optional (isLinux && cfg.desktop.enable) sourcetrail
      ++ optional isDarwin gnupg;

    dotfiles.pinentry-mac.enable = mkDefault isDarwin;
  };
}
