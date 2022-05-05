{ config, lib, ... }:

let
  cfg = config.dotfiles.nix;
  nixPath = lib.concatStringsSep ":" cfg.nixPath;
in
{
  options.dotfiles.nix = {
    nixPath = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      example = [
        "/nix/var/nix/profiles/per-user/root/channels"
        "nixpkgs=https://nixos.org/channels/nixpkgs-unstable"
      ];
      description = ''
        Additional directories to prepend to the Nix expression search path.

        It is used by the Nix evaluator to look up paths enclosed in angle
        brackets (e.g. <literal>&lt;nixpkgs&gt;</literal>).
      '';
    };
  };

  config = lib.mkIf (cfg.nixPath != [ ]) {
    home.sessionVariablesExtra = ''
      export NIX_PATH="${nixPath}''${NIX_PATH:+:$NIX_PATH}"
    '';
  };
}
