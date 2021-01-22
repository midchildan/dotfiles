{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  inherit (lib.generators) toPlist;

  cfg = config.dotfiles.launchd;

  launchdConfig = { config, name, ... }: {
    options = {
      enable = mkEnableOption name;
      config = mkOption {
        type = types.submodule (import ./launchd.nix);
        default = { };
        example = {
          ProgramArguments = [ "/usr/bin/say" "Good afternoon" ];
          StartCalendarInterval = {
            Hour = 12;
            Minute = 0;
          };
        };
        description = ''
          Define a launchd job. See <citerefentry>
          <refentrytitle>launchd.plist</refentrytitle><manvolnum>5</manvolnum>
          </citerefentry> for details.
        '';
      };
    };

    config = { config.Label = mkDefault "${cfg.labelPrefix}.${name}"; };
  };

  stageDir = "${config.xdg.dataHome}/home-manager/LaunchAgents";
  dstDir = "${config.home.homeDirectory}/Library/LaunchAgents";

  toAgent = config: pkgs.writeText "${config.Label}.plist" (toPlist { } config);

  agents' =
    mapAttrs' (n: v: nameValuePair "${v.config.Label}.plist" (toAgent v.config))
    (filterAttrs (n: v: v.enable) cfg.agents);

  agents = pkgs.runCommandNoCC "home-manager-agents" {
    srcs = attrValues agents';
    dsts = attrNames agents';
  } ''
    mkdir -p $out

    if [[ -n "$srcs" ]]; then
      for (( i=0; i < "''${#srcs[@]}"; i+=1 )); do
        src="''${srcs[i]}"
        dst="''${dsts[i]}"
        ln -s "$src" "$out/$dst"
      done
    fi
  '';
in {
  options = {
    dotfiles.launchd = {
      labelPrefix = mkOption {
        type = types.str;
        default = "org.nixos";
        description = "The default prefix for launchd job labels.";
      };

      agents = mkOption {
        type = with types; attrsOf (submodule launchdConfig);
        default = { };
        description = "Define launchd agents.";
      };
    };
  };

  config = mkIf isDarwin {
    home.activation.installLaunchAgents =
      hm.dag.entryAfter [ "writeBoundary" ] ''
        bash '${./launchd-activate.sh}' '${agents}' '${stageDir}' '${dstDir}'
      '';
  };
}
