{ config, lib, pkgs, ... }:

let
  isDir = path: builtins.pathExists (path + "/.");

  darwinDir = (builtins.getEnv "HOME") + "/.config/nixpkgs/darwin.d";
  darwinDirFiles =
    if isDir darwinDir
    then builtins.attrNames (builtins.readDir darwinDir)
    else [ ];

  toAbsolute = path: darwinDir + ("/" + path);
  isValidConfigPath = path:
    let
      isConfFile = builtins.match ".*\\.nix" path != null;
      isConfDir = builtins.pathExists ((toAbsolute path) + "/default.nix");
    in
    isConfFile || isConfDir;
in
{
  # Read the config from a non-default location. Note that the following
  # command would need to be run upon initial setup:
  #
  # $ darwin-rebuild switch -I darwin-config=~/.config/nixpkgs/darwin.nix
  environment.darwinConfig = "$HOME/.config/nixpkgs/darwin.nix";

  # import all files matching ~/.config/nixpkgs/darwin.d/{*.nix,*/default.nix}
  imports = map toAbsolute (lib.filter isValidConfigPath darwinDirFiles);

  # Setup Nix and the Nix daemon. After nix-darwin has been activated, it should
  # be safe to remove the copy of Nix from the default profile.
  #
  # $ sudo -H nix-channel --remove nixpkgs
  # $ sudo -H nix-env -e '*'
  nix.package = lib.mkDefault pkgs.nix;
  services.nix-daemon.enable = lib.mkDefault true;

  # Disable shell configuration
  programs.bash.enable = lib.mkDefault false;
  programs.zsh.enable = lib.mkDefault false;

  # ... and instead gather required environment variables in /etc/nix/darwin.sh
  environment.etc."nix/darwin.sh".source = config.system.build.setEnvironment;

  environment.variables = let
    # override nix-darwin defaults (priority 1000)
    mkDefault = lib.mkOverride 900;
  in {
    EDITOR = mkDefault "\${EDITOR:-vim}";
    PAGER = mkDefault "\${PAGER:-less}";
  };

  # HACK: make nix-darwin preserve system PATH
  environment.systemPath = lib.mkForce [
    (lib.makeBinPath config.environment.profiles)
    "\"$PATH\""
  ];
}
