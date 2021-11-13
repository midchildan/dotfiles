{ lib
, stdenvNoCC
, fetchurl
, noto-fonts-cjk
}:

stdenvNoCC.mkDerivation rec {
  pname = "noto-serif-cjk";
  version = "2021-10-27";
  rev = "9f7f3c38eab63e1d1fddd8d50937fe4f1eacdb1d";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/googlefonts/noto-cjk/${rev}/Serif/Variable/OTC/NotoSerifCJK-VF.otf.ttc";
    sha256 = "sha256-zthnY8sUP/d8SbCXS3iQ1Pn4LPlJFj4k1aQUf4fihIc=";
  };

  buildCommand = ''
    install -m444 -Dt $out/share/fonts/opentype/noto-cjk ${src}
  '';

  meta = with lib; (noto-fonts-cjk.meta // {
    maintainers = with maintainers; [ midchildan ];
  });
}
