{ config, lib, pkgs, ... }:

{
  # Setup Nix and the Nix daemon. After nix-darwin has been activated, it should
  # be safe to remove the copy of Nix from the default profile.
  #
  # $ sudo -H nix-channel --remove nixpkgs
  # $ sudo -H nix-env -e '*'
  nix.package = lib.mkDefault pkgs.nix_2_4;
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

  # FIXME: workaround for https://github.com/LnL7/nix-darwin/pull/450
  system.defaults.finder.FXPreferredViewStyle = lib.mkDefault null;
}
