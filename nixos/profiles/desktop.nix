{ config, lib, pkgs, dotfiles, ... }:

with lib;

let
  cfg = config.dotfiles.profiles.desktop;
  myPkgs = dotfiles.packages.${system};
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (config.dotfiles.profiles.interactive) username;
in
{
  options.dotfiles.profiles.desktop = {
    enable = mkEnableOption "configuration for desktop environments";
    desktop = mkOption {
      type = types.enum [ "gnome" "kde" ];
      default = "gnome";
      description = "Which DM to use.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      dotfiles.profiles.interactive.enable = true;

      console.useXkbConfig = mkDefault true;
      hardware.pulseaudio.enable = mkDefault true;

      i18n = {
        inputMethod = {
          enabled = mkDefault "ibus";
          ibus.engines = with pkgs.ibus-engines; [ mozc ];
        };
      };

      fonts = {
        fontDir.enable = true;
        fonts = with pkgs; [
          noto-fonts
          noto-fonts-cjk
          myPkgs.noto-serif-cjk
          noto-fonts-emoji
          ipafont
          dejavu_fonts
        ];
        fontconfig.defaultFonts = {
          monospace = [ "Noto Sans Mono CJK JP" "Noto Sans Mono" ];
          serif = [ "Noto Serif CJK JP" "Noto Serif" ];
          sansSerif = [ "Noto Sans CJK JP" "Noto Sans" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };

      services = {
        pcscd.enable = mkDefault true;
        printing.enable = mkDefault true;
      };

      services.xserver = {
        enable = true;
        layout = mkDefault "us";
      };

      programs.qt5ct.enable = mkDefault true;

      programs.gnupg.agent = {
        enable = mkDefault true;
        enableSSHSupport = mkDefault true;
      };

      virtualisation.libvirtd.enable = mkDefault true;
      users.users.${username}.extraGroups = [ "networkmanager" "libvirtd" ];
    }

    (mkIf (cfg.desktop == "gnome") {
      environment.gnome.excludePackages = with pkgs.gnome; [ gnome-music ];

      services.gnome = {
        core-os-services.enable = true;
        core-shell.enable = true;
        core-utilities.enable = true;
      };

      services.xserver = {
        displayManager.gdm.enable = mkDefault true;
        desktopManager.gnome.enable = mkDefault true;
      };

      services.tlp.enable = false;
    })

    (mkIf (cfg.desktop == "kde") {
      services.xserver = {
        displayManager.sddm.enable = mkDefault true;
        desktopManager.plasma5.enable = mkDefault true;
      };
    })
  ]);
}
