{ lib, stdenv, Foundation }:

stdenv.mkDerivation {
  pname = "aquaskk-reload-config";
  version = "1.0.0";

  src = ./.;

  buildInputs = [ Foundation ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "A tool to make AquaSKK reload its configuration.";
    homepage = "https://github.com/midchildan/dotfiles";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ midchildan ];
  };
}
