# overlay for the nixpkgs input to this flake

final: prev:

# FIXME: workaround for https://github.com/NixOS/nixpkgs/pull/146517
prev.lib.optionalAttrs prev.stdenv.isDarwin {
  clang-tools = prev.clang-tools.override {
    llvmPackages = prev.llvmPackages_12;
  };
}
