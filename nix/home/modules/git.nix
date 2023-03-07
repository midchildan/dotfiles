{ lib, pkgs, config, ... }:

let
  cfg = config.dotfiles.git;
  inherit (pkgs.gitAndTools) delta;
in
{
  options.dotfiles.git = {
    config = lib.mkOption {
      type = with lib.types; attrsOf (attrsOf anything);
      default = { };
      example = {
        rebase.autosquash = true;
      };
      description = ''
        Configuration for git. This option is meant to be used in conjunction
        with existing non-Home Manager configuration, so it's not written out
        directly to the global gitconfig. Instead, it's written to
        <filename>~/.config/git/hmconfig</filename> meant to be included by
        existing configurations.

        For specific options, see the CONFIGURATION FILE section of
        <citerefentry>
          <refentrytitle>git-config</refentrytitle>
          <manvolnum>1</manvolnum>
        </citerefentry>.
      '';
    };
    enableDelta = lib.mkEnableOption "Git syntax highlighting with Delta";
  };

  config = lib.mkMerge [
    {
      xdg.configFile."git/hmconfig".text = lib.generators.toGitINI cfg.config;
    }
    (lib.mkIf cfg.enableDelta {
      home.packages = [ delta ];
      dotfiles.git.config = {
        core.pager = "${delta}/bin/delta";
        interactive.diffFilter = "${delta}/bin/delta --color-only";
      };
    })
  ];
}
