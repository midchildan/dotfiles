{ lib, runCommand, darwin, nixUnstable }:

let
  # Create a nix-darwin configuration that includes almost nothing other than
  # nix-darwin itself.
  tinyConfig = {
    nix.package = nixUnstable;
    documentation.info.enable = false;
    programs.bash.enable = false;
  };

  tinyDarwin = darwin.lib.darwinSystem {
    modules = [ tinyConfig ];
  };

  tinySystem = tinyDarwin.system;
in
runCommand "nix-darwin"
{
  meta = {
    description = "Command line tool for nix-darwin";
    longDescription = ''
      Provides command line tools from nix-darwin. This package is mainly useful
      for bootstrapping nix-darwin.
    '';
    license = with lib.licenses; [ mit ];
    homepage = "https://github.com/LnL7/nix-darwin";
    platforms = lib.platforms.darwin;
  };
} ''
  mkdir -p "$out/bin" "$out/share/man/man5"
  ln -s "${tinySystem}/sw/bin/darwin-help" "$out/bin/darwin-help"
  ln -s "${tinySystem}/sw/bin/darwin-option" "$out/bin/darwin-option"
  ln -s "${tinySystem}/sw/bin/darwin-rebuild" "$out/bin/darwin-rebuild"
  ln -s "${tinySystem}/sw/share/man/man5/configuration.nix.5" \
    "$out/share/man/man5/configuration.nix.5"
''
