{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule rec {
  pname = "mmdbctl";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "ipinfo";
    repo = "mmdbctl";
    rev = "mmdbctl-${version}";
    hash = "sha256-K+eZ8a/TJrzR4iYu3vbNDlXeRoLuTYEAw0yoRqMJpyI=";
  };

  vendorHash = "sha256-k+/VPxCDNw8J3opPL7zuU6Kk4rp76UbacvdI/14Iedc=";

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
