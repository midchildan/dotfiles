{ config, lib, pkgs, ... }:

let
  cfg = config.dotfiles.vim;

  vimrcWithPlugins = pkgs.vimUtils.vimrcContent {
    beforePlugins = null;
    packages.home-manager = cfg.plugins;
  };

  # HACK: extract packdir from generated vimrc
  #
  # There's a plan to make a cleaner approach possbile:
  # https://github.com/NixOS/nixpkgs/pull/136429#issuecomment-920879649
  packDir = pkgs.runCommand "packdir" {
    vimrc = vimrcWithPlugins;
  } ''
    ln -s "$(sed -n 's/set packpath.=\([^\n]*\)/\1/p' <<<"$vimrc")/pack" $out
  '';

  inherit (lib) literalExample mkOption types;
in
{
  options.dotfiles.vim.plugins = mkOption {
    type = types.submodule {
      options = {
        opt = lib.mkOption {
          type = with types; listOf package;
          default = [ ];
          example = literalExample "with pkgs.vimPlugins; [ coc-nvim ]";
          description = ''
            Installs plugins to be loaded manually with
            <literal>:packadd</literal>.
          '';
        };
        start = lib.mkOption {
          type = with types; listOf package;
          default = [ ];
          example = literalExample "with pkgs.vimPlugins; [ coc-nvim ]";
          description = ''
            Installs plugins to be loaded automatically at startup.
          '';
        };
      };
    };
    description = "Install the specified vim plugins.";
  };

  config = lib.mkIf (cfg.plugins.opt != [ ] || cfg.plugins.start != [ ]) {
    home.file.".vim/pack".source = packDir;
  };
}
