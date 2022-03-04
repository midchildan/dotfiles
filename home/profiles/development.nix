{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  isNixOS = isLinux && !isGenericLinux;
  cfg = config.dotfiles.profiles;
in
{
  options.dotfiles.profiles.development.enable =
    mkEnableOption "development packages";

  config = mkIf cfg.development.enable {
    home.packages = with pkgs;
      [ cargo clang-tools github-cli go gopls shellcheck tokei universal-ctags ]
      ++ optionals (cfg.desktop.enable && !isDarwin) [ sourcetrail ]
      ++ optionals isNixOS [ man-pages ]
      ++ optionals isDarwin [ gnupg ];

    dotfiles.pinentry-mac.enable = mkDefault isDarwin;

    dotfiles.vim.plugins.start = with pkgs.vimPlugins; [
      coc-clangd
      coc-cmake
      coc-go
      coc-rust-analyzer
      coc-pyright
      coc-tsserver
    ];
  };
}
