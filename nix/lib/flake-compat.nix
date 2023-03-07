{ src ? ./../.., ... } @ args:

let
  lock = with builtins; fromJSON (readFile ../../flake.lock);
  flake-compat = rec {
    inherit (lock.nodes.flake-compat.locked) owner repo rev;
    src = fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      sha256 = lock.nodes.flake-compat.locked.narHash;
    };
  };
in
import flake-compat.src (args // { inherit src; })
