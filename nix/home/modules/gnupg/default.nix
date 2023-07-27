{ lib, config, pkgs, dotfiles, ... }:

let
  cfg = config.dotfiles.gnupg;
  pinentry-mac = "${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac";
in
{
  options.dotfiles.gnupg = {
    enable = lib.mkEnableOption "GnuPG";

    enablePackage = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc "Whether to install the GnuPG package.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gnupg;
      defaultText = lib.literalExpression "pkgs.gnupg";
      description = lib.mdDoc "The GnuPG package to use.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = lib.optional cfg.enablePackage cfg.package;

      home.file.".gnupg/gpg.conf".source = pkgs.substituteAll {
        src = ./gpg.conf;
        gpgKey = dotfiles.lib.config.user.gpgKey or "@removeMe@";
        postInstall = ''
          sed -i '/@removeMe@/d' "$target"
        '';
      };
    }

    (lib.mkIf pkgs.stdenv.isDarwin {
      home.file.".gnupg/gpg-agent.conf".text = ''
        pinentry-program ${pinentry-mac}
      '';

      # FIXME: workaround for https://github.com/NixOS/nixpkgs/issues/155629
      home.file.".gnupg/scdaemon.conf".source = ./scdaemon.conf;

      launchd.agents.gpg-agent = lib.mkIf cfg.enablePackage {
        enable = true;
        config = {
          ProgramArguments = [
            "${cfg.package}/bin/gpgconf"
            "--launch"
            "gpg-agent"
          ];
          RunAtLoad = true;
        };
      };
    })
  ]);
}
