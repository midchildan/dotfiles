{ config, lib, pkgs, ... }:

let cfg = config.dotfiles.profiles.hardware;
in
{
  options.dotfiles.profiles.hardware = {
    enable = lib.mkEnableOption "configuration for physical hardware";
    hidpi.enable = lib.mkEnableOption "configuration for HiDPI displays";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      boot.loader = {
        systemd-boot.enable = lib.mkDefault true;
        systemd-boot.editor = lib.mkDefault false;
        efi.canTouchEfiVariables = lib.mkDefault true;
      };

      hardware = {
        enableAllFirmware = lib.mkDefault true;
        cpu.intel.updateMicrocode = lib.mkDefault true;
      };

      services = {
        fwupd.enable = lib.mkDefault true;
        thermald.enable = lib.mkDefault true;
        tlp.enable = lib.mkDefault true;
      };
    })
    (lib.mkIf (cfg.enable && cfg.hidpi.enable) {
      boot.loader.systemd-boot.consoleMode = lib.mkDefault "1";
      console.font = lib.mkDefault "latarcyrheb-sun32";
      environment.variables.QT_AUTO_SCREEN_SCALE_FACTOR = lib.mkDefault "1";
    })
  ];
}
