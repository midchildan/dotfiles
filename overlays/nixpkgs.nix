# overlay for the nixpkgs input to this flake

final: prev:

# Workaround for https://github.com/NixOS/nixpkgs/pull/146517
prev.lib.optionalAttrs prev.stdenv.isDarwin {
  clang-tools = prev.clang-tools.override {
    llvmPackages = prev.llvmPackages_12;
  };
}
