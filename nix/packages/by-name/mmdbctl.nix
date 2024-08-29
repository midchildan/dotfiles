{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule rec {
  pname = "mmdbctl";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "ipinfo";
    repo = "mmdbctl";
    rev = "mmdbctl-${version}";
    hash = "sha256-6hJ9V8fHs84Lq48l3mB9nZka4rLneyxD4HMhWQYZ0cI=";
  };

  vendorHash = "sha256-5vd39j/gpRRkUccctKGU8+QL0vANm2FMyw6jTtoqJmw=";

  doCheck = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version-regex"
      "mmdbctl-(.*)"
    ];
  };

  meta = {
    description = "MMDB file management CLI";
    homepage = "https://github.com/ipinfo/mmdbctl";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ midchildan ];
  };
}
