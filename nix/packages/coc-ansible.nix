{ lib
, buildVimPluginFrom2Nix
, fetchFromGitHub
, fetchYarnDeps
, mkYarnPackage
}:

let
  pname = "coc-ansible";

  yarnPackage = mkYarnPackage rec {
    inherit pname;
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

    configurePhase = ''
      runHook preConfigure
      ln -s $node_modules node_modules
      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild
      yarn --offline build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r . $out
      runHook postInstall
    '';
  };
in
buildVimPluginFrom2Nix rec {
  inherit pname;
  inherit (yarnPackage) version;

  src = yarnPackage;

  meta = with lib; {
    description = "An ansible-language-server extension for coc.nvim";
    homepage = "https://github.com/yaegassy/coc-ansible";
    license = licenses.mit;
    maintainers = with maintainers; [ midchildan ];
  };
}
