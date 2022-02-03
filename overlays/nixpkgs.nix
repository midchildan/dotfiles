# overlay for the nixpkgs input to this flake

final: prev:

prev.lib.optionalAttrs (prev.stdenv.isDarwin) {
  # TODO: remove after https://github.com/NixOS/nixpkgs/pull/158008 is merged
  nghttp3 = prev.nghttp3.overrideAttrs (old: {
    checkInputs = (old.checkInputs or [ ]) ++ (with prev; [ ncurses ]);
    meta = old.meta // {
      platforms = prev.lib.platforms.unix;
    };
  });

  # TODO: remove after https://github.com/NixOS/nixpkgs/pull/158008 is merged
  ngtcp2 = prev.ngtcp2.overrideAttrs (old: {
    buildInputs = prev.lib.filter (p: p.pname != "jemalloc") old.buildInputs;
    checkInputs = (old.checkInputs or [ ]) ++ (with prev; [ ncurses ]);
    meta = old.meta // {
      platforms = prev.lib.platforms.unix;
    };
  });
}
