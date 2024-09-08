{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotfiles.vim;
  inherit (config.dotfiles) flakeOptions;

  vimPackDrv = pkgs.vimUtils.packDir { home-manager = cfg.plugins; };
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
    default = { };
    description = "Install the specified vim plugins.";
  };

  config = lib.mkMerge [
    {
      home.file.".vim/plugin/hmvars.vim".text = ''
        let g:snips_author = '${flakeOptions.user.name}'
        let g:snips_email = '${flakeOptions.user.email}'
        let g:snips_github = 'https://github.com/${flakeOptions.user.name}'
      '';
    }
    (lib.mkIf (cfg.plugins.opt != [ ] || cfg.plugins.start != [ ]) {
      home.file = {
        ".vim/pack/home-manager".source = "${vimPackDrv}/pack/home-manager";
      };
    })
  ];
}
