# overlay for the nixpkgs input to this flake

final: prev:

prev.lib.optionalAttrs prev.stdenv.isDarwin rec {
  python3 = prev.python3.override {
    packageOverrides = final: prev: {
      # FIXME: workaround for https://nixpk.gs/pr-tracker.html?pr=159516
      ipython = prev.ipython.overridePythonAttrs (old: {
        disabledTests = [ "test_clipboard_get" ];
      });

      # TODO: remove the following workarounds along with the ipython workaround
      #
      # These tests seems too flaky on GitHub Actions.
      passlib = prev.passlib.overridePythonAttrs (old: {
        disabledTests = [ "test_dummy_verify" ];
      });
      magic-wormhole = prev.magic-wormhole.overridePythonAttrs (old: {
        disabledTests = [ "test_plugins_upgrade" ];
      });
    };
  };
  python3Packages = python3.pkgs;
}
