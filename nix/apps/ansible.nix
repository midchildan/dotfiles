{ lib
, ansible
, python3Packages
, writers
}:

let
  binPath = lib.makeBinPath [
    ansible
    python3Packages.jmespath
  ];
in
writers.writeBash "ansible.sh" ''
  set -euo pipefail

  export PATH="${binPath}''${PATH:+:$PATH}"
  exec ansible-playbook ${lib.escapeShellArg ../../ansible/site.yml} "$@"
''
