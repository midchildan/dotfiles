{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  inherit (lib) escapeShellArg;
  inherit (lib.generators) toPlist;
  inherit (hm.dag) entryAfter;

  cfg = config.dotfiles.launchd;
  labelPrefix = "org.nixos";
  dstDir = "${config.home.homeDirectory}/Library/LaunchAgents";

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

    config = { config.Label = mkDefault "${labelPrefix}.${name}"; };
  };

  toAgent = config: pkgs.writeText "${config.Label}.plist" (toPlist { } config);

  agentPlists =
    mapAttrs' (n: v: nameValuePair "${v.config.Label}.plist" (toAgent v.config))
      (filterAttrs (n: v: v.enable) cfg.agents);

  agentsDrv = pkgs.runCommand "home-manager-agents"
    {
      srcs = attrValues agentPlists;
      dsts = attrNames agentPlists;
    } ''
    mkdir -p "$out"

    if [[ -n "$srcs" ]]; then
      for (( i=0; i < "''${#srcs[@]}"; i+=1 )); do
        src="''${srcs[i]}"
        dst="''${dsts[i]}"
        ln -s "$src" "$out/$dst"
      done
    fi
  '';
in
{
  options.dotfiles.launchd.agents = mkOption {
    type = with types; attrsOf (submodule launchdConfig);
    default = { };
    description = "Define launchd agents.";
  };

  config = mkIf isDarwin {
    home.extraBuilderCommands = ''
      ln -s "${agentsDrv}" $out/LaunchAgents
    '';

    home.activation.checkLaunchAgents = hm.dag.entryBefore [ "writeBoundary" ] ''
      checkLaunchAgents() {
        local oldDir="$(readlink -m "$oldGenPath/LaunchAgents")"
        local newDir=${escapeShellArg agentsDrv}
        local dstDir=${escapeShellArg dstDir}

        local oldSrcPath newSrcPath dstPath agentFile agentName

        find -L "$newDir" -maxdepth 1 -name '*.plist' -type f -print0 \
            | while IFS= read -rd "" newSrcPath; do
          agentFile="''${newSrcPath##*/}"
          agentName="''${agentFile%.plist}"
          dstPath="$dstDir/$agentFile"
          oldSrcPath="$oldDir/$agentFile"

          if [[ ! -e "$dstPath" ]]; then
            continue
          fi

          if ! cmp --quiet "$oldSrcPath" "$dstPath"; then
            errorEcho "Existing file '$dstPath' is in the way of '$newSrcPath'"
            exit 1
          fi
        done
      }

      checkLaunchAgents
    '';

    # NOTE: Launch Agent configurations can't be symlinked from the Nix store
    # because it needs to be owned by the user running it.
    home.activation.setupLaunchAgents = hm.dag.entryAfter [ "writeBoundary" ] ''
      setupLaunchAgents() {
        local oldDir="$(readlink -m "$oldGenPath/LaunchAgents")"
        local newDir="$(readlink -m "$newGenPath/LaunchAgents")"
        local dstDir=${escapeShellArg dstDir}
        local domain="gui/$UID"

        local srcPath dstPath agentFile agentName

        find -L "$newDir" -maxdepth 1 -name '*.plist' -type f -print0 \
            | while IFS= read -rd "" srcPath; do
          agentFile="''${srcPath##*/}"
          agentName="''${agentFile%.plist}"
          dstPath="$dstDir/$agentFile"

          if cmp --quiet "$srcPath" "$dstPath"; then
            continue
          fi
          if [[ -f "$dstPath" ]]; then
            $DRY_RUN_CMD launchctl bootout "$domain/$agentName" || :
          fi
          $DRY_RUN_CMD install -Dm644 -T "$srcPath" "$dstPath"
          $DRY_RUN_CMD launchctl bootstrap "$domain" "$dstPath"
        done

        if [[ ! -e "$oldDir" ]]; then
          return
        fi

        find -L "$oldDir" -maxdepth 1 -name '*.plist' -type f -print0 \
            | while IFS= read -rd "" srcPath; do
          agentFile="''${srcPath##*/}"
          agentName="''${agentFile%.plist}"
          dstPath="$dstDir/$agentFile"
          if [[ -e "$newDir/$agentFile" ]]; then
            continue
          fi

          $DRY_RUN_CMD launchctl bootout "$domain/$agentName" || :
          if [[ ! -e "$dstPath" ]]; then
            continue
          fi
          if ! cmp --quiet "$srcPath" "$dstPath"; then
            warnEcho "Skipping deletion of '$dstPath', since its contents have diverged"
            continue
          fi
          $DRY_RUN_CMD rm -f $VERBOSE_ARG "$dstPath"
        done
      }

      setupLaunchAgents
    '';
  };
}
