{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, pkg-config
, cunit
, ncurses
}:

stdenv.mkDerivation rec {
  pname = "nghttp3-unstable";
  version = "2021-09-20";

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  checkInputs = [ cunit ncurses ];

  src = fetchFromGitHub {
    owner = "ngtcp2";
    repo = "nghttp3";
    rev = "b40c49c630d1a0a895c397553293cda72192a213";
    sha256 = "sha256-Rzc2VEjEn2ifTfQZZVMlZvKwO3l4/m47Je/n1vmIzMs=";
  };

  doCheck = true;
  enableParallelBuilding = true;

  meta = with lib; {
    description = "HTTP/3 library written in C";
    homepage = "https://github.com/ngtcp2/nghttp3";
    license = licenses.mit;
    maintainers = with maintainers; [ midchildan ];
  };
}
