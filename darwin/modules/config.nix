{ config, lib, pkgs, ... }:

{
  # Setup Nix and the Nix daemon. After nix-darwin has been activated, it should
  # be safe to remove the copy of Nix from the default profile.
  #
  # $ sudo -H nix-channel --remove nixpkgs
  # $ sudo -H nix-env -e '*'
  nix.package = lib.mkDefault pkgs.nixVersions.nix_2_8;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = lib.mkDefault true;

  # Disable shell configuration
  programs.bash.enable = lib.mkDefault false;
  programs.zsh.enable = lib.mkDefault false;

  # ... and instead gather required environment variables in /etc/nix/darwin.sh
  environment.etc."nix/darwin.sh".source = config.system.build.setEnvironment;

  # ... and expose shell completion too
  environment.pathsToLink = [
    "/etc/bash_completion.d"
    "/share/bash-completion"
    "/share/zsh"
  ];

  environment.variables =
    let
      # override nix-darwin defaults (priority 1000)
      mkDefault = lib.mkOverride 900;
    in
    {
      EDITOR = mkDefault "vim";
      PAGER = mkDefault "less";
    };

  # HACK: make nix-darwin preserve system PATH
  environment.systemPath = lib.mkForce [
    (lib.makeBinPath config.environment.profiles)
    "\"$PATH\""
  ];

  # FIXME: somebody's personal preference made it into the upstream defaults
  system.defaults = {
    ActivityMonitor = {
      OpenMainWindow = lib.mkDefault null;
      ShowCategory = lib.mkDefault null;
    };
  };
}
