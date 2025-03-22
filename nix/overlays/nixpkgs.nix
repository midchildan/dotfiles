# overlay for the nixpkgs input to this flake

final: prev:

{
  luaPackages = prev.luaPackages.overrideScope (
    _: lprev: {
      fzf-lua = lprev.fzf-lua.override (old: {
        patches = (old.patches or [ ]) ++ [ ./fzf-lua-fix-flaky-test.patch ];
      });
    }
  );
}
