{ lib
, buildVimPlugin
, fetchFromGitHub
, fetchYarnDeps
, mkYarnPackage
, cacert
}:

let
  pname = "coc-ansible";

  yarnPackage = mkYarnPackage rec {
    inherit pname;
    version = "0.14.2";

    src = fetchFromGitHub {
      owner = "yaegassy";
      repo = "coc-ansible";
      rev = "v${version}";
      sha256 = "sha256-BJQ6FA4FRs7vaQX1NZ593gazRkaCWrZ2G+zPy+ISXMs=";
    };

    packageJSON = "${src}/package.json";
    yarnLock = "${src}/yarn.lock";
    offlineCache = fetchYarnDeps {
      yarnLock = "${src}/yarn.lock";
      sha256 = "sha256-urBprEeGoA41LQnLzg+HGwGdaCgAGKy/Sn5EM0VQ5I8=";

      # TODO: Follow the below discussion. Same solution was attempted there.
      # https://github.com/NixOS/nixpkgs/pull/265771/files#r1398252435
      NODE_EXTRA_CA_CERTS = "${cacert}/etc/ssl/certs/ca-bundle.crt";
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
buildVimPlugin rec {
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
