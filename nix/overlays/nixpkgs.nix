# overlay for the nixpkgs input to this flake

final: prev:

let
  pkgsFrom = args: import (prev.fetchFromGitHub args) { inherit (prev) config system; };
in
{
  nix-update = prev.nix-update.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      # github: Add fallback to atom feed if project does not use releases
      (prev.fetchpatch {
        url = "https://github.com/Mic92/nix-update/commit/7840def89c26efbb9039efbd4e631b1ade4b2956.patch";
        hash = "sha256-yUzrwlauSA+2cI0/o4Y09fneGmx7QPB+I5ac9P2L5Xo=";
      })
    ];
  });
}
// prev.lib.optionalAttrs prev.stdenv.isDarwin {
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
