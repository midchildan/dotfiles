{
  config,
  lib,
  pkgs,
  pkgsStable,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  cfg = config.dotfiles.profiles;
  isGenericLinux = (config.targets.genericLinux.enable or false);
in
{
  options.dotfiles.profiles.debugTools.enable = lib.mkEnableOption "debugging tools";

  config = lib.mkIf cfg.debugTools.enable {
    home.packages =
      with pkgs;
      [
        nmap
        socat
      ]
      ++ lib.optionals isLinux [
        binutils
        powertop
        radare2
        valgrind
        pkgsStable.linuxPackages.bcc
        (lowPrio pkgsStable.linuxPackages.bpftrace)
      ]
      ++ lib.optionals (isLinux && cfg.desktop.enable) [ pkgsStable.cutter ];
  };
}
