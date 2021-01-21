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

          <warning>
            <para>
              Starting launchd jobs upon switching Home Manager generations
              isn't supported yet. To start the job without logging out, you'll
              need to do it manually with <command>launchctl load -w</command>.
            </para>
          </warning>
        '';
      };
    };

    config = { config.Label = mkDefault "${cfg.labelPrefix}.${name}"; };
  };

  stageDir = "${config.xdg.dataHome}/home-manager/LaunchAgents";
  dstDir = "${config.home.homeDirectory}/Library/LaunchAgents";

  toAgent = config: pkgs.writeText "${config.Label}.plist" (toPlist { } config);

  agents' = mapAttrs'
    (n: v: nameValuePair "${v.config.Label}.plist" (toAgent v.config))
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
    home.activation = {
      # NOTE: Launch Agent configurations can't be symlinked from the Nix store
      # because it needs to be owned by the user running it.
      installLaunchAgents = hm.dag.entryAfter [ "writeBoundary" ] ''
        installLaunchAgents() {
          local f

          $DRY_RUN_CMD rm -rf $VERBOSE_ARG "${stageDir}" || :
          $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "${dstDir}" "${stageDir}"

          find -L "${agents}" -type f -print0 | while IFS= read -rd "" f; do
            $DRY_RUN_CMD install $VERBOSE_ARG -Dm644 -t "${stageDir}" "$f"
          done

          find -L "${stageDir}" -type f -print0 | while IFS= read -rd "" f; do
            $DRY_RUN_CMD ln -sf $VERBOSE_ARG "$f" "${dstDir}"
          done

          find "${dstDir}" -xtype l -print0 | while IFS= read -rd "" f; do
            if [[ "$(readlink "$f")" == "${stageDir}"* ]]; then
              $DRY_RUN_CMD rm $VERBOSE_ARG "$f"
            fi
          done
        }
        installLaunchAgents
      '';
    };
  };
}
