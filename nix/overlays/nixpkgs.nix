# overlay for the nixpkgs input to this flake

final: prev:

{
  # TODO: remove
  # https://github.com/NixOS/nixpkgs/pull/263951
  cutter = prev.cutter.override { python3 = prev.python310; };

}
