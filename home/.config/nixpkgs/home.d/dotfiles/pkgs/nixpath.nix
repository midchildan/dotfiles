{ runCommandNoCC, nix }:

runCommandNoCC "nix.sh" {
  meta = {
    description = "Workaround for  https://github.com/NixOS/nix/issues/2033";
    priority = (nix.meta.priority or 0) + 1;
  };
} ''
  mkdir -p $out/etc/profile.d
  ln -s ${nix}/etc/profile.d/nix.sh $out/etc/profile.d
''
