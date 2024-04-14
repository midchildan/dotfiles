# Copyright (c) 2003-2023 Eelco Dolstra and the Nixpkgs/NixOS contributors
# Copyright (c) midchildan
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# meta.updateScript handling is based on
# https://github.com/NixOS/nixpkgs/blob/231ffe1/maintainers/scripts/update.nix

{ lib
, path
, coreutils
, curl
, gawk
, git
, gnugrep
, gnused
, jq
, nix
, python3
, runtimeShellPackage
, writers

, packages
, max-workers ? null
}:

let
  packageList = lib.mapAttrsToList
    (attrPath: package: {
      inherit attrPath package;
    })
    packages;

  checkEligibility = p: lib.hasAttr "updateScript" p.package;
  updatables = lib.filter checkEligibility packageList;

  somewhatUniqueRepresentant = p: {
    inherit (p.package) updateScript;
    # Some updaters use the same `updateScript` value for all packages.
    # Also compare `meta.description`.
    position = p.package.meta.position or null;
    # We cannot always use `meta.position` since it might not be available
    # or it might be shared among multiple packages.
  };

  # Remove duplicate elements from the list based on some extracted value.
  # O(n^2) complexity.
  #
  nubOn = f: list:
    if list == [ ] then
      [ ]
    else
      let
        x = lib.head list;
        xs = lib.filter (p: f x != f p) (lib.drop 1 list);
      in
      [ x ] ++ nubOn f xs;

  uniqueUpdatables = nubOn somewhatUniqueRepresentant updatables;

  # Transform a matched package into an object for update.py.
  #
  packageData = { package, attrPath }: {
    name = package.name;
    pname = lib.getName package;
    oldVersion = lib.getVersion package;
    updateScript = map builtins.toString (
      lib.toList (package.updateScript.command or package.updateScript));
    supportedFeatures = package.updateScript.supportedFeatures or [ ];
    attrPath = package.updateScript.attrPath or attrPath;
  };

  # JSON file with data for update.py.
  #
  packagesJson =
    writers.writeJSON "packages.json" (map packageData uniqueUpdatables);

  updaterArgs = [
    python3.interpreter
    "${path}/maintainers/scripts/update.py"
    packagesJson
  ]
  ++ lib.optional (max-workers != null) "--max-workers=${max-workers}";

  binPath = lib.makeBinPath [
    coreutils
    curl
    gawk
    git
    gnugrep
    gnused
    jq
    nix
    runtimeShellPackage
  ];
in
writers.writeBash "update.sh" ''
  set -euo pipefail

  PACKAGES_ONLY=

  for arg in "$@"; do
    case "$arg" in
      --packages-only) PACKAGES_ONLY=1 ;;
      --verbose) set -x ;;
    esac
  done

  export PATH=${lib.escapeShellArg binPath}

  if ! [[ -f flake.nix && -d nix/packages ]] ||
    [[ "$(git rev-parse --is-inside-work-tree)" != "true" ]]; then
    printf '[ERROR] This script appears to be run from the wrong directory. ' >&2
    printf 'Re-run this script from the root of the dotfiles repository.\n' >&2
  fi

  printf 'Updating packages...\n'
  ${lib.escapeShellArgs updaterArgs} <<<$'\n'

  if [[ -n "$PACKAGES_ONLY" ]]; then
    exit
  fi

  printf 'Updating flake inputs...\n'
  nix flake update

  printf 'Updating git submodules...\n'
  git submodule update --init --remote
''
