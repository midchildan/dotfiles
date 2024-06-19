{ config, mkShellNoCC }:

mkShellNoCC {
  inherit (config.treefmt.build.devShell) nativeBuildInputs;
  shellHook = config.pre-commit.installationScript;
}
