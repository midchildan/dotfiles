# overlay for the nixpkgs input to this flake

final: prev:

prev.lib.optionalAttrs prev.stdenv.isDarwin rec {
  python3 = prev.python3.override {
    packageOverrides = final: prev: {
      # FIXME: tests seems to be flaky
      httpie = prev.httpie.overridePythonAttrs (old: {
        disabledTestPaths = (old.disabledTestPaths or [ ]) ++ [
          "tests/test_plugins_cli.py"
        ];

        disabledTests = (old.disabledTests or [ ]) ++ [
          "test_stdin_read_warning"
          "test_daemon_runner"
        ];
      });
    };
  };
  python3Packages = python3.pkgs;
}
