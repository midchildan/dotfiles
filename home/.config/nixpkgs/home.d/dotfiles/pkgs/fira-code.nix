{ runCommandNoCC, fira-code }:

runCommandNoCC "fira-code" {
  meta = {
    inherit (fira-code.meta) description homepage license;
  };
} ''
  install -Dm644 \
    ${fira-code}/share/fonts/truetype/FiraCode-VF.ttf \
    $out/share/fonts/truetype/FiraCode-VF.ttf
''
