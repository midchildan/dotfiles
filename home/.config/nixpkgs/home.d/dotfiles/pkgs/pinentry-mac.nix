{ stdenvNoCC, makeWrapper, pinentry_mac }:

stdenvNoCC.mkDerivation {
  inherit (pinentry_mac) name;

  nativeBuildInputs = [ makeWrapper ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper \
      ${pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac \
      $out/bin/pinentry-mac
  '';

  meta = {
    inherit (pinentry_mac.meta) homepage description license platforms;
  };
}
