# overlay for the nixpkgs input to this flake

final: prev:

{
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
}
