{
  lib,
  python3,
  writers,
}:

let
  python = python3.withPackages (
    ps: with ps; [
      ansible-core
      jmespath
    ]
  );

  binPath = lib.makeBinPath [ python ];
in
writers.writeBash "ansible.sh" ''
  set -euo pipefail

  export PATH="${binPath}''${PATH:+:$PATH}"
  exec ansible-playbook ${lib.escapeShellArg ../../ansible/site.yml} "$@"
''
