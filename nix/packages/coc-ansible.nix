{ lib
, buildVimPluginFrom2Nix
, fetchFromGitHub
, fetchYarnDeps
, mkYarnPackage
}:

let
  yarnPackage = mkYarnPackage rec {
    pname = "coc-ansible";
    version = "0.13.5";

    src = fetchFromGitHub {
      owner = "yaegassy";
      repo = "coc-ansible";
      rev = "v${version}";
      sha256 = "sha256-SEMKFmfxfFRlKRDfgocvCQkaUm1FHPWrXWPeG9IIWHY=";
    };

    packageJSON = "${src}/package.json";
    yarnLock = "${src}/yarn.lock";
    offlineCache = fetchYarnDeps {
      yarnLock = "${src}/yarn.lock";
      sha256 = "sha256-SfaN/6HsVag5PKaqDm+rCuS+WusX7soWONKqtbWt7/Q=";
    };

    doDist = false;
    buildPhase = "yarn --offline build";
  };
in
buildVimPluginFrom2Nix rec {
  inherit (yarnPackage) pname version;
  src = "${yarnPackage}/libexec/${pname}/deps/${pname}";
  meta = with lib; {
    description = "An ansible-language-server extension for coc.nvim";
    homepage = "https://github.com/yaegassy/coc-ansible";
    license = licenses.mit;
    maintainers = with maintainers; [ midchildan ];
  };
}
