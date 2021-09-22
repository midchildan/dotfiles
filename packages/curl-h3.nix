{ lib
, stdenv
, curl
, fetchurl
, autoreconfHook
, quictls
, nghttp3
, ngtcp2
, SystemConfiguration
}:

let
  inherit (lib) any filter hasSuffix optionals versionAtLeast;

  version = "7.79.0";

  curl-quictls = curl.override {
    openssl = quictls;
  };

  patchesToExclude = optionals (versionAtLeast version "7.77.0") [
    "CVE-2021-22897.patch"
    "CVE-2021-22898.patch"
    "CVE-2021-22901.patch"
  ];

  excludePatches = filenames:
    let hasSameFilenameAs = path: name: lib.hasSuffix name (toString path);
    in filter (patch: !(any (hasSameFilenameAs patch) filenames));
in
curl-quictls.overrideAttrs (old: {
  inherit version;

  src = fetchurl {
    url = "https://curl.haxx.se/download/${old.pname}-${version}.tar.bz2";
    sha256 = "sha256-1gemd/Rz95+WyWQQAycSWmIEo52DXcANq3/AEpuVn0I=";
  };

  patches = excludePatches patchesToExclude (old.patches or [ ]);

  nativeBuildInputs = old.nativeBuildInputs ++ [ autoreconfHook ];
  buildInputs = (old.buildInputs or [ ]) ++ optionals stdenv.isDarwin [
    # Ongoing issue at https://github.com/NixOS/nixpkgs/pull/124502
    SystemConfiguration
  ];

  configureFlags = old.configureFlags ++ [
    "--with-nghttp3=${nghttp3}"
    "--with-ngtcp2=${ngtcp2}"
  ];
})
