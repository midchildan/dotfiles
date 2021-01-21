{ config, lib, pkgs, ... }:

with lib;

let inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in {
  options = {
    dotfiles.syncthing.enable = mkEnableOption "Syncthing file synchronization";
  };

  config = mkIf config.dotfiles.syncthing.enable (mkMerge [
    { services.syncthing.enable = isLinux; }

    (mkIf isDarwin {
      home.packages = [ (getOutput "man" pkgs.syncthing) ];

      dotfiles.launchd.agents.syncthing = {
        enable = true;
        config = {
          ProgramArguments =
            [ "${pkgs.syncthing}/bin/syncthing" "-no-browser" "-no-restart" ];
          KeepAlive = {
            Crashed = true;
            SuccessfulExit = false;
          };
          ProcessType = "Background";
        };
      };
    })
  ]);
}
