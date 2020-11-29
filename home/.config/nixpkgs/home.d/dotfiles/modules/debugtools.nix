{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dotfiles;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  nixos = if isGenericLinux then pkgs else (import <nixos> { });
in {
  options.programs.dotfiles.debugTools.enable =
    mkEnableOption "Debugging tools";

  config = mkIf cfg.debugTools.enable {
    home.packages = with pkgs;
      [ binutils nmap pwndbg radare2 socat valgrind ]
      ++ optional (isLinux && cfg.desktop.enable) radare2-cutter
      ++ optionals isLinux (with nixos.linuxPackages; [
        bcc
        (nixos.callPackage ../pkgs/bpftrace.nix { })
      ]);
  };
}
