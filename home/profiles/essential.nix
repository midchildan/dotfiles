{ config, lib, pkgs, dotfiles, ... }:

let
  inherit (lib) mkDefault mkEnableOption mkIf optionals;
  inherit (pkgs.stdenv.hostPlatform) isDarwin system;
  myPkgs = dotfiles.packages.${system};
in
{
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
        gitstatus
        httpie
        jq
        lsof
        magic-wormhole
        neofetch
        nixpkgs-fmt
        nkf
        ranger
        tig
        tmux
        wget
        zsh-completions
        gitAndTools.git-absorb
        nodePackages.prettier
      ] ++ optionals (!isDarwin) [
        dnsutils
        file
        libarchive
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
