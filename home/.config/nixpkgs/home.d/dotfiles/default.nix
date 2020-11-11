{ ... }:

{
  imports = [
    ./modules/minimal.nix
    ./modules/essential.nix
    ./modules/debugtools.nix
    ./modules/desktop.nix
    ./modules/development.nix
    ./news.nix
  ];
}
