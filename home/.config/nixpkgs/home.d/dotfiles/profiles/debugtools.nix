{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.dotfiles.profiles;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  nixos = if isGenericLinux then pkgs else (import <nixos> { });
  extraNixos = import ../pkgs { pkgs = nixos; };
in {
  options.dotfiles.profiles.debugTools.enable =
    mkEnableOption "debugging tools";

  config = mkIf cfg.debugTools.enable {
    home.packages = with pkgs;
      [ nmap socat ] ++ optionals isLinux [
        binutils
        pwndbg
        radare2
        valgrind
        nixos.linuxPackages.bcc
        extraNixos.bpftrace
      ] ++ optional (isLinux && cfg.desktop.enable) radare2-cutter;
  };
}
