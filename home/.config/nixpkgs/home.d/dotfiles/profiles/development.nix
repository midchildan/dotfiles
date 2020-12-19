{ config, lib, pkgs, ... }:

with lib;

let inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  options.dotfiles.profiles.development.enable =
    mkEnableOption "Development packages";

  config = mkIf config.dotfiles.profiles.development.enable {
    home.packages = with pkgs;
      [ cargo clang-tools github-cli go gopls shellcheck tokei universal-ctags ]
      ++ (with pkgs.vimPlugins; [ coc-go coc-rust-analyzer coc-tsserver ])
      ++ optional isDarwin gnupg;

    dotfiles.pinentry-mac.enable = mkDefault isDarwin;
  };
}
