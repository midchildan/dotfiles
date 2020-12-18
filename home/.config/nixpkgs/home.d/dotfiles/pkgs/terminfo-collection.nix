{ stdenvNoCC, kitty }:

stdenvNoCC.mkDerivation {
  name = "terminfo-collection";

  phases = [ "installPhase" ];

  installPhase = ''
    install -D \
      "${kitty.src}/terminfo/x/xterm-kitty" $out/share/terminfo/x/xterm-kitty
  '';

  meta = {
    description = "Collection of terminfo definitions";
    license = kitty.meta.license;
    priority = 10;
  };
}
