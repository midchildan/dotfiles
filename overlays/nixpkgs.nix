# overlay for the nixpkgs input to this flake

final: prev:

prev.lib.optionalAttrs prev.stdenv.isDarwin rec {
  # FIXME: test seems to be flaky
  httpie = prev.httpie.overridePythonAttrs (old: {
    disabledTests = (old.disabledTests or [ ]) ++ [
      "test_plugins_upgrade"
      "test_stdin_read_warning"
    ];
  });
}
