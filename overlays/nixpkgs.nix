# overlay for the nixpkgs input to this flake

final: prev:

rec {
  # FIXME: remove when fix reaches nixpkgs-unstable
  # https://nixpk.gs/pr-tracker.html?pr=153486
  python3 = prev.python3.override {
    packageOverrides = final: prev: {
      capstone = prev.capstone.overrideAttrs (_: {
        sourceRoot = "source/bindings/python";
      });
    };
  };
  python3Packages = python3.pkgs;
}
