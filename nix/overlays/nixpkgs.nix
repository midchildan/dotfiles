# overlay for the nixpkgs input to this flake

final: prev:

{
  vimPlugins = prev.vimPlugins // {
    fzf-lua = prev.vimPlugins.fzf-lua.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./fzf-lua-fix-flaky-test.patch ];
    });
  };
}
