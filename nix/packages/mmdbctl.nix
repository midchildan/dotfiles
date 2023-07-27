{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "mmdbctl";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "ipinfo";
    repo = "mmdbctl";
    rev = "mmdbctl-${version}";
    hash = "sha256-idvTjBCHhqsbffUOJHSa7sCR3bfzU8X4ZHog4RxRaec=";
  };

  vendorHash = "sha256-QS5PoIO0SmJK8/yoQTkYBVyvZW8anA4tYqaC1mrVEBU=";

  doCheck = true;

  meta = {
    description = "MMDB file management CLI";
    homepage = "https://github.com/ipinfo/mmdbctl";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ midchildan ];
  };
}
