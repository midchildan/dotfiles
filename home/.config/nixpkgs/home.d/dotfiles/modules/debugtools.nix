{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  nixos = if isGenericLinux then pkgs else (import <nixos> { });
  extraNixos = import ../pkgs { pkgs = nixos; };
in {
  options.profiles.debugTools.enable = mkEnableOption "Debugging tools";

  config = mkIf cfg.debugTools.enable {
    home.packages = with pkgs;
      [ binutils nmap pwndbg radare2 socat valgrind ]
      ++ optionals isLinux [ nixos.linuxPackages.bcc extraNixos.bpftrace ]
      ++ optional (isLinux && cfg.desktop.enable) radare2-cutter;
  };
}
