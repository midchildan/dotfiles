# overlay for the nixpkgs input to this flake

final: prev:

prev.lib.optionalAttrs prev.stdenv.isDarwin {
  # FIXME: workaround for https://github.com/NixOS/nixpkgs/pull/146517
  clang-tools = prev.clang-tools.override {
    llvmPackages = prev.llvmPackages_12;
  };

  # FIXME: workaround for https://github.com/Homebrew/homebrew-core/pull/88595
  socat = prev.socat.overrideAttrs (old: {
    patches = [ ./socat-fix-feature-check-tcpinfo.patch ];
  });
}
