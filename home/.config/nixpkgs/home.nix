{ ... }:

with builtins;

let
  isDir = path: pathExists (path + "/.");

  hmDir = (getEnv "HOME") + "/.config/nixpkgs/home.d";
  hmDirFiles = if isDir hmDir then attrNames (readDir hmDir) else [];

  toAbsolute = path: hmDir + ("/" + path);
  isValidConfigPath = path: let
    isConfFile = match ".*\\.nix" path != null;
    isConfDir = pathExists ((toAbsolute path) + "/default.nix");
  in
    isConfFile || isConfDir;
in
{
  # import all files matching ~/.config/nixpkgs/home/{*.nix,*/default.nix}
  imports = map toAbsolute (filter isValidConfigPath hmDirFiles);

  programs.home-manager.enable = true;
}
