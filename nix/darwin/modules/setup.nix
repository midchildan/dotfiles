{ lib, ... }:

{
  system.activationScripts.preUserActivation.text = lib.mkBefore ''
    if ! [ -L /run ] && ! grep -q '^run\b' /etc/synthetic.conf; then
      printf 'setting up /run via /etc/synthetic.conf...\n'
      printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf >/dev/null
      sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t &>/dev/null || true
      if ! [ -L /run ]; then
        printf 'error: failed to create symlink /run\n'
        false
      fi
    fi
  '';
}
