#!/usr/bin/env bash
# shellcheck disable=SC2086

set -euo pipefail

DRY_RUN="${DRY_RUN:-}"
DRY_RUN_CMD="${DRY_RUN_CMD:-}"
VERBOSE_ARG="${VERBOSE_ARG:-}"
WORKDIR="$(mktemp -d)"

cleanup() {
  rm -rf "$WORKDIR" || :
}
trap cleanup EXIT

main() {
  local agents="$1" # path to Nix store directory containing Launch Agents
  local stageDir="$2" # user-owned path to copy the Launch Agents to
  local dstDir="$3" # path to user Launch Agents directory
  local f newStageDir oldStageDir=''

  if [[ -L "$stageDir" ]]; then
    oldStageDir="$(realpath "$stageDir")"
  fi
  if [[ -z "$DRY_RUN" ]]; then
    newStageDir="$(mktemp -d "$stageDir.XXX")"
  else
    mkdir LaunchAgents
    newStageDir="$PWD/LaunchAgents"
  fi

  # copy Launch Agents from Nix store
  #
  # NOTE: Launch Agent configurations can't be symlinked from the Nix store
  # because it needs to be owned by the user running it.

  find -L "$agents" -maxdepth 1 -name '*.plist' -type f -print0 \
    | while IFS= read -rd "" f; do
      install -Dm644 -t "$newStageDir" "$f"
  done

  # generate suggestions

  if [[ -d "$oldStageDir" ]]; then
    generateSuggestions "$oldStageDir" "$newStageDir" "$dstDir" \
      > suggestions.txt
  fi

  # switch to new configuration

  $DRY_RUN_CMD mkdir $VERBOSE_ARG -p "$dstDir"

  find -L "$newStageDir" -type f -printf '%f\0' | while IFS= read -rd "" f; do
    $DRY_RUN_CMD ln -sf $VERBOSE_ARG "$stageDir/$f" "$dstDir" || :
  done

  $DRY_RUN_CMD ln -sfT $VERBOSE_ARG "$newStageDir" "$stageDir"

  # remove old config

  if [[ -d "$oldStageDir" ]]; then
    $DRY_RUN_CMD rm -rf $VERBOSE_ARG "$oldStageDir"
  fi

  find "${dstDir}" -xtype l -print0 | while IFS= read -rd "" f; do
    if [[ "$(readlink "$f")" == "$stageDir"* ]]; then
      $DRY_RUN_CMD rm $VERBOSE_ARG "$f"
    fi
  done

  # show suggestions

  if [[ -s suggestions.txt ]]; then
    echo "Suggested commands:"
    cat suggestions.txt
  fi
}

generateSuggestions() {
  local oldStageDir="$1"
  local newStageDir="$2"
  local dstDir="$3"

  find \
    "$oldStageDir" -maxdepth 1 -name '*.plist' -type f -printf "$dstDir/%f\\n" \
    | sort \
    > old_agents.txt
  find \
    "$newStageDir" -maxdepth 1 -name '*.plist' -type f -printf "$dstDir/%f\\n" \
    | sort \
    > new_agents.txt

  diff \
    --new-line-format='+%L' \
    --old-line-format='-%L' \
    --unchanged-line-format=' %L' \
    old_agents.txt new_agents.txt \
    | awk '
        /^ / {
          printf "launchctl unload %s\n", substr($0,2,length($0))
          printf "launchctl load %s\n", substr($0,2,length($0))
        }
        /^-/ {
          printf "launchctl unload %s\n", substr($0,2,length($0))
        }
        /^\+/ {
          printf "launchctl load -w %s\n", substr($0,2,length($0))
        }
      ' \
    || :
}

pushd "$WORKDIR" > /dev/null
main "$@"
popd > /dev/null
