{ fetchFromGitHub, openssl }:

openssl.overrideAttrs(_: {
  version = "1.1.1l+quic";
  src = fetchFromGitHub {
    owner = "quictls";
    repo = "openssl";
    rev = "f7e2b9a89838769039ddea4214a31b66c78a8651";
    sha256 = "sha256-NGFta8SvEuYhiEgSet4ZUXy6xQGpknsUf9luIygR43I=";
  };
})
