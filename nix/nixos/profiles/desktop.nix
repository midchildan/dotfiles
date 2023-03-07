{ config, lib, pkgs, pkgsUnstable, ... }:

with lib;

let
  cfg = config.dotfiles.profiles.desktop;
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
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
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
        flatpak.enable = mkDefault true;
        pcscd.enable = mkDefault true;
      };

      # Printers https://nixos.wiki/wiki/Printing
      services.printing = {
        enable = true;
        drivers = with pkgs; [ gutenprint ];
      };

      # Scanners https://nixos.wiki/wiki/Scanners
      hardware.sane = {
        enable = mkDefault true;
        extraBackends = with pkgs; [ sane-airscan ];
      };

      services.xserver = {
        enable = true;
        layout = mkDefault "us";
        excludePackages = [ pkgs.xterm ];
      };

      programs.gnupg.agent = {
        enable = mkDefault true;
        enableSSHSupport = mkDefault true;
      };

      users.users.${username}.extraGroups = [ "networkmanager" ];
    }

    (mkIf (cfg.desktop == "gnome") {
      environment.systemPackages = with pkgs.gnome; [ gnome-session ];
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
