{ config, lib, ... }:

{
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
}
