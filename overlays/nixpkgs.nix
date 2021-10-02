# overlay for the nixpkgs input to this flake

final: prev:

prev.lib.optionalAttrs (prev.stdenv.isDarwin) {

  python3 = prev.python3.override {
    packageOverrides = final: prev: {
      # TODO: remove temporary fix
      #   issue https://github.com/NixOS/nixpkgs/pull/137870
      #   status in https://nixpk.gs/pr-tracker.html?pr=137870
      beautifulsoup4 = prev.beautifulsoup4.overridePythonAttrs (_: {
        disabledTests = [
          "test_real_hebrew_document"
          "test_smart_quotes_converted_on_the_way_in"
          "test_can_parse_unicode_document"
        ];
      });
    };
  };

  python3Packages = final.python3.pkgs;

  # TODO: investigate why installCheck fails
  thefuck = prev.thefuck.overrideAttrs (_: { doInstallCheck = false; });
}
