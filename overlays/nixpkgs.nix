# overlay for the nixpkgs input to this flake

final: prev:

let
  inherit (prev) lib;
  inherit (prev.stdenv.hostPlatform) isUnix isStatic;
in
lib.optionalAttrs (isUnix && isStatic) {
  # TODO: Remove once the following issue is fixed:
  # https://github.com/NixOS/nixpkgs/pull/172892
  ncurses = prev.ncurses.overrideAttrs (old: {
    configureFlags = old.configureFlags ++ [
      # For static binaries, the point is to have a standalone binary with
      # minimum dependencies. So the following makes sure that binaries using
      # this package won't depend on a terminfo database located in the Nix
      # store.
      "--with-terminfo-dirs=${lib.concatStringSep ":" [
        "/etc/terminfo" # Debian, Fedora, Gentoo
        "/lib/terminfo" # Debian
        "/usr/share/terminfo" # upstream default, probably all FHS-based distros
        "/run/current-system/sw/share/terminfo" # NixOS
      ]}"
    ];
  });
}
