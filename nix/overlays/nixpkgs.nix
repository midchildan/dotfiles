# overlay for the nixpkgs input to this flake

final: prev:

let
  inherit (prev.unixtools) locale;

  python3 = prev.python3.override {
    packageOverrides = final: prev: {
      # FIXME: works around the following error
      # > FileNotFoundError: [Errno 2] No such file or directory: 'locale'
      magic-wormhole = prev.magic-wormhole.overridePythonAttrs (old: {
        nativeCheckInputs = (old.nativeCheckInputs or [ ]) ++ [ locale ];
      });
    };
  };
in
{
  # TODO: remove
  # https://github.com/NixOS/nixpkgs/pull/263951
  cutter = prev.cutter.override { python3 = prev.python310; };

} // prev.lib.optionalAttrs prev.stdenv.isDarwin {
  magic-wormhole = with python3.pkgs; toPythonApplication magic-wormhole;
}
