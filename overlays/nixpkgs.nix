# overlay for the nixpkgs input to this flake

final: prev:

# FIXME: remove when fix reaches nixpkgs-unstable
# https://nixpk.gs/pr-tracker.html?pr=147289
prev.lib.optionalAttrs prev.stdenv.isDarwin {
  clang-tools = prev.clang-tools.override {
    llvmPackages = prev.llvmPackages_12;
  };
}
