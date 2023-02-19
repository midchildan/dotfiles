{ config, lib, ... }:

let
  cfg = config.dotfiles.nix;
  nixPath = lib.concatStringsSep ":" cfg.nixPath;

  inherit (lib) literalExpression mapAttrs' mkIf mkMerge mkOption nameValuePair;
in
{
  options.dotfiles.nix = {
    nixPath = mkOption {
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

    channels = mkOption {
      type = with lib.types; attrsOf package;
      default = { };
      example = literalExpression "{ inherit nixpkgs; }";
      description = ''
        A declarative alternative to Nix channels. Whereas with stock channels,
        you would register URLs and fetch them into the Nix store with
        <citerefentry>
          <refentrytitle>nix-channel</refentrytitle>
          <manvolnum>1</manvolnum>
        </citerefentry>,
        this option allows you to register the store path directly. One
        particularly useful example is registering flake inputs as channels.

        This option can coexist with stock Nix channels. If the same channel is
        defined in both, this option takes precedence.
      '';
    };
  };

  config = mkMerge [
    (mkIf (cfg.nixPath != [ ]) {
      home.sessionVariablesExtra = ''
        export NIX_PATH="${nixPath}''${NIX_PATH:+:$NIX_PATH}"
      '';
    })

    (mkIf (cfg.channels != { }) {
      home.file = mapAttrs'
        (name: store:
          nameValuePair
            # The directory name is prefixed with a number to make it easier for
            # files in ~/.nix-defexpr to control the order they'll be read
            # relative to each other.
            ".nix-defexpr/50-dotfiles/${name}"
            { source = store.outPath; })
        cfg.channels;
    })
  ];
}
