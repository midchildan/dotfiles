{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin system;
  cfg = config.dotfiles.profiles.essential;
  myPkgs = dotfiles.packages.${system};
in
{
  options.dotfiles.profiles.essential = {
    enable = lib.mkEnableOption "essential packages for servers and desktops alike";

    installCommonPackages = lib.mkOption {
      type = lib.types.bool;
      default = !isDarwin;
      description = "Whether to install packages commonly preinstalled in Linux distros.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        bat
        broot
        fd
        fselect
        ghq
        gitstatus
        httpie
        jq
        lsof
        magic-wormhole
        nkf
        ranger
        tig
        tmux
        wget
        zsh-completions
        gitAndTools.git-absorb
        nodePackages.prettier
      ]
      ++ lib.optionals cfg.installCommonPackages [
        dnsutils
        file
        libarchive
        git
        netcat
        whois
        myPkgs.terminfo-collection
      ]
      ++ lib.optionals isDarwin [
        ssh-copy-id
        watch
      ];

    dotfiles = {
      git.enableDelta = lib.mkDefault true;
      manpages.colorize = lib.mkDefault true;
    };
  };
}
