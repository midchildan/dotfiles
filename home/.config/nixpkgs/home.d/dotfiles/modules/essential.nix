{ config, lib, pkgs, ... }:

with lib;

{
  options.programs.dotfiles.essential.enable =
    mkEnableOption "Essential packages for servers and desktops alike";

  config = mkIf config.programs.dotfiles.essential.enable {
    home.packages = with pkgs;
      [
        bat
        broot
        cmigemo
        dnsutils
        file
        fd
        fselect
        ghq
        git
        httpie
        jq
        lsof
        magic-wormhole
        neofetch
        netcat
        nixfmt
        nkf
        nyancat
        p7zip
        ranger
        tig
        tmux
        wget
        whois
        nodePackages.prettier
      ] ++ (with pkgs.gitAndTools; [ delta diff-so-fancy git-absorb ]);
  };
}
