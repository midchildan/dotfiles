{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, pkg-config
, libev
, nghttp3
, quictls
, cunit
, ncurses
}:

stdenv.mkDerivation rec {
  pname = "ngtcp2-unstable";
  version = "2021-09-20";

  src = fetchFromGitHub {
    owner = "ngtcp2";
    repo = "ngtcp2";
    rev = "cb4a805e1fa9ace4941adcd55aba0bd9e2a8513c";
    sha256 = "sha256-qkFgM4qI8ATcE+NIpEnuFjjFlkzYgpxA1xEgFOYvSU8=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [ libev nghttp3 quictls ];
  checkInputs = [ cunit ncurses ];

  doCheck = true;
  enableParallelBuilding = true;

  meta = with lib; {
    description = "Implemenatation of the IETF QUIC protocol";
    homepage = "https://github.com/ngtcp2/ngtcp2";
    license = licenses.mit;
    maintainers = with maintainers; [ midchildan ];
  };
}
