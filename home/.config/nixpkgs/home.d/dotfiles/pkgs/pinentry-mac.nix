{ runCommandNoCC, makeWrapper, pinentry_mac }:

runCommandNoCC pinentry_mac.name {
  nativeBuildInputs = [ makeWrapper ];
  meta = {
    inherit (pinentry_mac.meta) homepage description license platforms;
  };
} ''
  mkdir -p $out/bin
  makeWrapper \
    ${pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac \
    $out/bin/pinentry-mac
''
