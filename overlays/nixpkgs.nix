# overlay for the nixpkgs input to this flake

final: prev:

prev.lib.optionalAttrs prev.stdenv.isDarwin rec {
  python3 = prev.python3.override {
    packageOverrides = final: prev: {
      # FIXME: workaround for https://github.com/NixOS/nixpkgs/issues/160133
      ipython = prev.ipython.overridePythonAttrs (old: {
        disabledTests = [ "test_clipboard_get" ];
      });
    };
  };
  python3Packages = python3.pkgs;
}
