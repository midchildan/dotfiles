# overlay for the nixpkgs input to this flake

final: prev:

{
  # TODO: remove
  # https://github.com/NixOS/nixpkgs/pull/263951
  cutter = prev.cutter.override { python3 = prev.python310; };

} // prev.lib.optionalAttrs prev.stdenv.isDarwin {
  # TODO: remove
  # https://github.com/NixOS/nixpkgs/pull/268563
  tokei = prev.tokei.overrideAttrs (old: {
    checkInputs = (old.checkInputs or [ ]) ++ [ prev.zlib ];
  });
}
