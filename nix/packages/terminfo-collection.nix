{ runCommand, kitty }:

runCommand "terminfo-collection"
  {
    meta = {
      description = "Collection of terminfo definitions";
      license = kitty.meta.license;
      priority = 10;
    };
  }
  ''
    install -Dm644 \
      "${kitty.src}/terminfo/x/xterm-kitty" $out/share/terminfo/x/xterm-kitty
  ''
