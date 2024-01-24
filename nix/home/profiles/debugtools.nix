{ config, lib, pkgs, nixos, ... }:

let
  cfg = config.dotfiles.profiles;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isGenericLinux = (config.targets.genericLinux.enable or false);
in
{
  options.dotfiles.profiles.debugTools.enable =
    lib.mkEnableOption "debugging tools";

  config = lib.mkIf cfg.debugTools.enable {
    home.packages = with pkgs;
      [ nmap socat ] ++ lib.optionals isLinux [
        binutils
        powertop
        pwndbg
        radare2
        valgrind
        nixos.linuxPackages.bcc
        (lowPrio nixos.linuxPackages.bpftrace)
      ] ++ lib.optionals (isLinux && cfg.desktop.enable) [
        cutter
      ];
  };
}
