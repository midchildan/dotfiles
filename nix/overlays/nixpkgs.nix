# overlay for the nixpkgs input to this flake

final: prev:

let
  pkgsFrom = args: import (prev.fetchFromGitHub args) { inherit (prev) config system; };
in
prev.lib.optionalAttrs prev.stdenv.isDarwin {
  inherit
    (pkgsFrom {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "2e92235aa591abc613504fde2546d6f78b18c0cd";
      hash = "sha256-7IAIo8dA+XxC9ARKl/xTXUWy5Y0p+JTRxJG6S11sKZg=";
    })
    swift # TODO: remove after https://github.com/NixOS/nixpkgs/issues/327836 is fixed
    ;
}
