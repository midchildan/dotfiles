# overlay for the nixpkgs input to this flake

final: prev:

{
  # Workaround for https://github.com/NixOS/nixpkgs/pull/286572
  defaultGemConfig = prev.defaultGemConfig // {
    jekyll = attrs:
      let
        old = prev.defaultGemConfig.jekyll attrs;
      in
      old // {
        dependencies = (old.dependencies or attrs.dependencies) ++ [
          "kramdown-parser-gfm"
        ];
      };
  };

  # there are two separate derivations for jekyll in Nixpkgs for some reason
  inherit (prev.rubyPackages) jekyll;

  # Fix compile errors
  cutter = prev.cutter.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (prev.fetchpatch {
        url = "https://github.com/rizinorg/cutter/commit/1a52a7e.patch";
        hash = "sha256-cn4nv+qQzt6qadVnpy/Dps8OfHm7P3G0HAHMtAccIRU=";
      })
      (prev.fetchpatch {
        url = "https://github.com/rizinorg/cutter/commit/2106551.patch";
        hash = "sha256-Mgyn7xLwM3JIIRBvbjplGVYiVYCGWTmsW2rYVgYUVrw=";
        includes = [ "src/widgets/GraphvizLayout.cpp" ];
      })
    ];
  });
}
