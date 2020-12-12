{ lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;

  localeArchiveEnvVars = {
    # The glibc package in nixpkgs is patched to make it possbile to specify
    # an alternative path for the locale archive through a special environment
    # variable. This would allow different versions of glibc to coexist on the
    # same system because each version of glibc could look up different paths
    # for its locale archive should the archive format ever change in
    # incompatible ways.
    #
    # See also:
    # localedef(1)
    # https://nixos.org/manual/nixpkgs/stable/#locales
    # https://github.com/NixOS/nixpkgs/issues/38991
    #
    # XXX: The name of this environment variable should be kept in sync with the
    # nixpkgs source. Failing to do so would break locale support. Periodically
    # check the below link for changes:
    # https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/development/libraries/glibc/nix-locale-archive.patch
    LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };
in {
  # TODO: this might be a good candidate for upstreaming to Home Manager
  config = mkIf isLinux {
    home.sessionVariables = localeArchiveEnvVars;
    systemd.user.sessionVariables = localeArchiveEnvVars;
  };
}
