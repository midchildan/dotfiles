# overlay for the nixpkgs input to this flake

final: prev:

{
  cutter = prev.cutter.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./cutter-pyside-2404.patch ];
  });
}
