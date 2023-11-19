{ config, lib, pkgs, ... }:

let
  cfg = config.dotfiles.nix;
  nixPath = lib.concatStringsSep ":" cfg.nixPath;

  useXdg = config.nix.enable
    && (config.nix.settings.use-xdg-base-directories or false);
  defexprDir =
    if useXdg then "${config.xdg.dataHome}/nix/defexpr"
    else "${config.home.homeDirectory}/.nix-defexpr";

  # The deploy path for declarative channels. The directory name is prefixed
  # with a number to make it easier for files in defexprDir to control the order
  # they'll be read relative to each other.
  channelPath = "${defexprDir}/50-dotfiles";

  channelsDrv =
    let mkEntry = name: drv: { inherit name; path = toString drv; };
    in pkgs.linkFarm "channels" (lib.mapAttrsToList mkEntry cfg.channels);
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
        brackets (e.g. `<nixpkgs>`).
      '';
    };

    channels = lib.mkOption {
      type = with lib.types; attrsOf package;
      default = { };
      example = lib.literalExpression "{ inherit nixpkgs; }";
      description = ''
        A declarative alternative to Nix channels. Whereas with stock channels,
        you would register URLs and fetch them into the Nix store with
        {manpage}`nix-channel(1)`, this option allows you to register the store
        path directly. One particularly useful example is registering flake
        inputs as channels.

        This option can coexist with stock Nix channels. If the same channel is
        defined in both, this option takes precedence.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.nixPath != [ ]) {
      home.sessionVariables.NIX_PATH = "${nixPath}\${NIX_PATH:+:$NIX_PATH}";
    })

    (lib.mkIf (cfg.channels != { }) {
      dotfiles.nix.nixPath = [ channelPath ];
      home.file."${channelPath}".source = channelsDrv;
    })
  ];
}
