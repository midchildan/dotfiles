{ config, lib, ... }:

with lib;

let cfg = config.dotfiles.manpages;
in {
  options.dotfiles.manpages.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Whether to enable manual pages. This is similar to
      <option>program.man.enable</option>, but doesn't install the man command.
      This helps ensure that the operating system's manual pages don't get
      hidden. See
      <link xlink:href="https://github.com/nix-community/home-manager/issues/432">nix-community/home-manager#432</link>
      for a related issue.
    '';
  };

  config = mkIf cfg.enable {
    programs.man.enable = false;
    home.extraOutputsToInstall = [ "man" ];
  };
}
