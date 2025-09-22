{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotfiles.profiles.desktop;
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (config.dotfiles.profiles.interactive) username;
in
{
  options.dotfiles.profiles.desktop = {
    enable = lib.mkEnableOption "configuration for desktop environments";
    type = lib.mkOption {
      type = lib.types.enum [
        "gnome"
        "plasma"
      ];
      default = "gnome";
      description = "Which DE to use.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        dotfiles.profiles.interactive.enable = true;

        console.useXkbConfig = lib.mkDefault true;

        i18n = {
          inputMethod = {
            enable = lib.mkDefault true;
            type = lib.mkDefault "ibus";
            ibus.engines = with pkgs.ibus-engines; [ mozc ];
          };
        };

        fonts = {
          fontDir.enable = true;
          packages = with pkgs; [
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts-emoji
            ipafont
            dejavu_fonts
          ];
          fontconfig.defaultFonts = {
            monospace = [
              "Noto Sans Mono CJK JP"
              "Noto Sans Mono"
            ];
            serif = [
              "Noto Serif CJK JP"
              "Noto Serif"
            ];
            sansSerif = [
              "Noto Sans CJK JP"
              "Noto Sans"
            ];
            emoji = [ "Noto Color Emoji" ];
          };
        };

        services = {
          flatpak.enable = lib.mkDefault true;
          pcscd.enable = lib.mkDefault true;
        };

        # Printers https://nixos.wiki/wiki/Printing
        services.printing = {
          enable = true;
          drivers = with pkgs; [ gutenprint ];
        };

        # Scanners https://nixos.wiki/wiki/Scanners
        hardware.sane = {
          enable = lib.mkDefault true;
          extraBackends = with pkgs; [ sane-airscan ];
        };

        services.xserver = {
          enable = true;
          xkb.layout = lib.mkDefault "us";
          excludePackages = [ pkgs.xterm ];
        };

        programs.gnupg.agent = {
          enable = lib.mkDefault true;
          enableSSHSupport = lib.mkDefault true;
        };

        users.users.${username}.extraGroups = [ "networkmanager" ];
      }

      (lib.mkIf (cfg.type == "gnome") {
        services.xserver.displayManager.gdm.enable = lib.mkDefault true;
        services.xserver.desktopManager.gnome.enable = lib.mkDefault true;

        services.gnome = {
          core-os-services.enable = true;
          core-shell.enable = true;
          core-apps.enable = true;
        };

        environment.systemPackages = [ pkgs.gnome-session ];
        environment.gnome.excludePackages = [ pkgs.gnome-music ];

        services.tlp.enable = false;
      })

      (lib.mkIf (cfg.type == "plasma") {
        services.displayManager.sddm.enable = lib.mkDefault true;
        services.desktopManager.plasma6.enable = lib.mkDefault true;

        services.tlp.enable = false;
      })
    ]
  );
}
