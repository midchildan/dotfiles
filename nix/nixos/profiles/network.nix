{ config, lib, pkgs, ... }:

let
  cfg = config.dotfiles.profiles.network;
  hasInteractiveCfg = config.dotfiles.profiles.interactive.enable;
in
{
  options.dotfiles.profiles.network.enable =
    lib.mkEnableOption "collection of network configurations";

  config = lib.mkIf cfg.enable {
    networking = {
      firewall = {
        enable = lib.mkDefault true;
        allowPing = lib.mkDefault false;
      };

      # container networking
      nat = {
        enable = lib.mkDefault true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = lib.mkDefault "eno1";
      };

      networkmanager = {
        enable = lib.mkDefault true;
        unmanaged = [ "interface-name:ve-*" ];
      };
    };

    services.avahi = {
      enable = lib.mkDefault true;
      nssmdns = lib.mkDefault true;
      ipv4 = lib.mkDefault true;
      ipv6 = lib.mkDefault true;
      publish.enable = lib.mkDefault true;
      publish.addresses = lib.mkDefault true;
    };

    services.openssh = lib.mkIf hasInteractiveCfg {
      enable = lib.mkDefault true;
      startWhenNeeded = lib.mkDefault true;
      forwardX11 = lib.mkDefault config.dotfiles.profiles.desktop.enable;
      passwordAuthentication = lib.mkDefault false;
      permitRootLogin = lib.mkDefault "no";
    };
  };
}
