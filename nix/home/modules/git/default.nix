{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.dotfiles.git;
  inherit (pkgs.gitAndTools) delta;
in
{
  options.dotfiles.git = {
    config = lib.mkOption {
      type = lib.types.submoduleWith {
        modules = [
          ./option.nix
          {
            _module.args = {
              inherit (config.dotfiles) flakeOptions;
            };
          }
        ];
        shorthandOnlyDefinesConfig = true;
      };
      default = { };
      example = {
        rebase.autosquash = true;
      };
      description = ''
        Configuration for git. This option is meant to be used in conjunction
        with existing non-Home Manager configuration, so it's not written out
        directly to the global gitconfig. Instead, it's written to
        {file}`~/.config/git/hmconfig` meant to be included by existing
        configurations.

        For specific options, see the CONFIGURATION FILE section of
        {manpage}`git-config(1)`.
      '';
    };
    enableDelta = lib.mkEnableOption "Git syntax highlighting with Delta";
  };

  config = lib.mkMerge [
    { xdg.configFile."git/hmconfig".text = lib.generators.toGitINI cfg.config; }
    (lib.mkIf cfg.enableDelta {
      home.packages = [ delta ];
      dotfiles.git.config = {
        core.pager = "${delta}/bin/delta";
        interactive.diffFilter = "${delta}/bin/delta --color-only";
      };
    })
  ];
}
