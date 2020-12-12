# include terminfo files from the Nix profile directory

{ config, pkgs, ... }:

let inherit (config.home) profileDirectory;
in {
  config = {
    home.sessionVariables.TERMINFO_DIRS =
      "${profileDirectory}/share/terminfo:$TERMINFO_DIRS\${TERMINFO_DIRS:+:}/usr/share/terminfo";

    home.sessionVariablesExtra = ''
      # apply the newly available terminfo descriptions
      export TERM="$TERM"
    '';
  };
}
