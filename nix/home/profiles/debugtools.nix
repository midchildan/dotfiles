{ config, lib, pkgs, ... }:

let
  cfg = config.dotfiles.profiles;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isGenericLinux = (config.targets.genericLinux.enable or false);

  # TODO: move this to NixOS system configuration
  # nixos = if isGenericLinux then pkgs else (import <nixos> { });
  # extraNixos = import ../pkgs { pkgs = nixos; };
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

        # TODO: move this to NixOS system configuration
        # nixos.linuxPackages.bcc
        # extraNixos.bpftrace
      ] ++ lib.optional (isLinux && cfg.desktop.enable) cutter;
  };
}
