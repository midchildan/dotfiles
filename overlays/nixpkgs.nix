# overlay for the nixpkgs input to this flake

final: prev:

prev.lib.optionalAttrs prev.stdenv.isDarwin rec {
  python3 = prev.python3.override {
    packageOverrides = final: prev: {
      # FIXME: workaround for https://nixpk.gs/pr-tracker.html?pr=159516
      ipython = prev.ipython.overridePythonAttrs (old: {
        disabledTests = (old.disabledTests or [ ]) ++ [ "test_clipboard_get" ];
      });

      # TODO: remove the following workarounds along with the ipython workaround
      #
      # These tests seems too flaky on GitHub Actions.
      passlib = prev.passlib.overridePythonAttrs (old: {
        disabledTests = (old.disabledTests or [ ]) ++ [ "test_dummy_verify" ];
      });
    };
  };
  python3Packages = python3.pkgs;

  httpie =
    let httpieWithGoodDeps = prev.httpie.override { inherit python3Packages; };
    in
    httpieWithGoodDeps.overridePythonAttrs (old: {
      disabledTests = (old.disabledTests or [ ]) ++ [
        "test_plugins_upgrade"
        "test_stdin_read_warning"
      ];
    });
}
