# This package is intended for use on stable Linux distributions with an
# outdated zsh package. Consider setting this as your login shell if the system
# provided zsh is giving you a hard time.

{ lib, runCommand, makeWrapper, glibcLocales, zsh }:

runCommand zsh.name
{
  nativeBuildInputs = [ makeWrapper ];
  meta = with lib; {
    inherit (zsh.meta) homepage license;
    platforms = platforms.linux;
    description = ''
      The Z shell. This package is intended for use on stable Linux
      distributions shipping an outdated version of zsh.
    '';
  };
} ''
  mkdir -p $out/bin

  # XXX: The name of the environment variable should be kept in sync with the
  # nixpkgs source. Failing to do so would break locale support. Periodically
  # check the below link for changes:
  # https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/development/libraries/glibc/nix-locale-archive.patch
  makeWrapper ${zsh}/bin/zsh $out/bin/zsh \
    --set LOCALE_ARCHIVE_2_27 "${glibcLocales}/lib/locale/locale-archive"
''
