{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  mkYarnPackage,
  cacert,
  nix-update-script,
  vimUtils,
}:

let
  pname = "coc-ansible";

  yarnPackage = mkYarnPackage rec {
    inherit pname;
    version = "0.14.3";

    src = fetchFromGitHub {
      owner = "yaegassy";
      repo = "coc-ansible";
      rev = "v${version}";
      hash = "sha256-tF0O9lhY0eML/RT7hN39NaV6dSq+vlfc9DSbPaJlR0s=";
    };

    packageJSON = "${src}/package.json";
    yarnLock = "${src}/yarn.lock";
    offlineCache = fetchYarnDeps {
      yarnLock = "${src}/yarn.lock";
      hash = "sha256-1QyloXlHuwClUyLR9CTtQa9lqUIMNLuTihETCYfB8nc=";

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
vimUtils.buildVimPlugin rec {
  inherit pname;
  inherit (yarnPackage) version;

  src = yarnPackage;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--url"
      src.src.url
    ];
  };

  meta = {
    description = "An ansible-language-server extension for coc.nvim";
    homepage = "https://github.com/yaegassy/coc-ansible";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ midchildan ];
  };
}
