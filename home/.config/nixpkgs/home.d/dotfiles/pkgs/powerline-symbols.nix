{ runCommandNoCC, powerline }:

runCommandNoCC "powerline-symbols" {
  meta = {
    inherit (powerline.meta) license;
    priority = (powerline.meta.priority or 0) + 1;
  };
} ''
  install -Dm644 \
    ${powerline.src}/font/PowerlineSymbols.otf \
    $out/share/fonts/OTF/PowerlineSymbols.otf
  install -Dm644 \
    ${powerline.src}/font/10-powerline-symbols.conf \
    $out/etc/fonts/conf.d/10-powerline-symbols.conf
''
