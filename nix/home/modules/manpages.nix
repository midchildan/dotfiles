{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotfiles.manpages;

  pager = pkgs.writeScript "batman" ''
    #!${pkgs.runtimeShell}
    col -bx | ${pkgs.bat}/bin/bat -l man -p "$@"
  '';
in
{
  options.dotfiles.manpages = {
    enable = lib.mkEnableOption "manpages";

    useSystemMan = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Install man pages, but don't install the man command. This helps ensure
        that the operating system's manual pages don't get hidden and avoid
        issues like [nix-community/home-manager#432](https://github.com/nix-community/home-manager/issues/432).

        When this option is disabled, {option}`program.man.enable` is enabled
        instead.
      '';
    };

    colorize = lib.mkEnableOption "colorized man pages";
  };

  config = lib.mkIf cfg.enable {
    programs.man.enable = !cfg.useSystemMan;
    home.extraOutputsToInstall = [ "man" ];

    home.sessionVariables = lib.mkIf cfg.colorize {
      MANPAGER = pager;
      MANROFFOPT = "-c";
    };
  };
}
