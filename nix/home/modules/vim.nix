{ config, lib, pkgs, ... }:

let
  cfg = config.dotfiles.vim;

  vimPackDrv = pkgs.vimUtils.packDir {
    home-manager = cfg.plugins;
  };
in
{
  options.dotfiles.vim.plugins = lib.mkOption {
    type = lib.types.submodule {
      options = {
        opt = lib.mkOption {
          type = with lib.types; listOf package;
          default = [ ];
          example = lib.literalExpression "with pkgs.vimPlugins; [ coc-nvim ]";
          description = ''
            Installs plugins to be loaded manually with `:packadd`.
          '';
        };
        start = lib.mkOption {
          type = with lib.types; listOf package;
          default = [ ];
          example = lib.literalExpression "with pkgs.vimPlugins; [ coc-nvim ]";
          description = ''
            Installs plugins to be loaded automatically at startup.
          '';
        };
      };
    };
    description = "Install the specified vim plugins.";
  };

  config = lib.mkIf (cfg.plugins.opt != [ ] || cfg.plugins.start != [ ]) {
    home.file = {
      ".vim/pack/home-manager".source = "${vimPackDrv}/pack/home-manager";
    };
  };
}
