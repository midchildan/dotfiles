{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.dotfiles.manpages;

  pager = with pkgs; writeScript "batman" ''
    #!${runtimeShell}
    col -bx | ${bat}/bin/bat -l man -p "$@"
  '';
in
{
  options.dotfiles.manpages = {
    enable = mkEnableOption "manpages";

    useSystemMan = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Install man pages, but don't install the man command. This helps ensure
        that the operating system's manual pages don't get hidden and avoid
        issues like
        <link xlink:href="https://github.com/nix-community/home-manager/issues/432">nix-community/home-manager#432</link>.

        When this option is disabled, <option>program.man.enable</option> is
        enabled instead.
      '';
    };

    colorize = mkEnableOption "colorized man pages";
  };

  config = mkIf cfg.enable {
    programs.man.enable = !cfg.useSystemMan;
    home.extraOutputsToInstall = [ "man" ];

    home.sessionVariables = mkIf cfg.colorize {
      MANPAGER = pager;
      MANROFFOPT = "-c";
    };
  };
}
