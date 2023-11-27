{ lib, stdenv, Foundation }:

stdenv.mkDerivation {
  pname = "aquaskk-reload-config";
  version = "1.0.0";

  src = ./.;

  buildInputs = [ Foundation ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "A tool to make AquaSKK reload its configuration.";
    homepage = "https://github.com/midchildan/dotfiles";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ midchildan ];
  };
}
