{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule rec {
  pname = "mmdbctl";
  version = "1.4.7";

  src = fetchFromGitHub {
    owner = "ipinfo";
    repo = "mmdbctl";
    rev = "mmdbctl-${version}";
    hash = "sha256-drYtuL4TzutzitLVKyUotxgyDjL7AMNnt0vVtfQhu4A=";
  };

  vendorHash = "sha256-4T3HEzRerC4KrGQnMNSW3OVzChUIf4yJ7qS9v8mWIX4=";

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
