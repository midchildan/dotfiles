{ config, lib, pkgs, dotfiles, ... }:

let
  inherit (lib) mkDefault mkEnableOption mkIf optionals;
  inherit (pkgs.stdenv.hostPlatform) isDarwin system;
  myPkgs = dotfiles.packages.${system};
in {
  options.dotfiles.profiles.essential.enable =
    mkEnableOption "essential packages for servers and desktops alike";

  config = mkIf config.dotfiles.profiles.essential.enable {
    home.packages = with pkgs;
      [
        bat
        broot
        cmigemo
        fd
        fselect
        ghq
        httpie
        jq
        lsof
        magic-wormhole
        neofetch
        nixpkgs-fmt
        nkf
        p7zip
        ranger
        thefuck
        tig
        tmux
        wget
        zsh-completions
        nodePackages.prettier
      ] ++ (with pkgs.gitAndTools; [ delta git-absorb ])
      ++ optionals (!isDarwin) [
        dnsutils
        file
        git
        netcat
        whois
        myPkgs.terminfo-collection
      ] ++ optionals isDarwin [
        ssh-copy-id
        watch
      ];

    dotfiles.manpages.colorize = mkDefault true;
  };
}
