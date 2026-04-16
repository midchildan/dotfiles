{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule rec {
  pname = "mmdbctl";
  version = "1.4.10";

  src = fetchFromGitHub {
    owner = "ipinfo";
    repo = "mmdbctl";
    rev = "mmdbctl-${version}";
    hash = "sha256-s1HKPZmuEENBf5a40i0oTtzvPV3UjMhS/1ijc9WtzXo=";
  };

  vendorHash = "sha256-f/FEMTOipss17uVhdvV3QKAmlHsmxnGWrz9csIs7ySk=";

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
