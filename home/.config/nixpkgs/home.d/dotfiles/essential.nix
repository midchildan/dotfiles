{ config, lib, pkgs, ... }:

with lib;

{
  options.programs.dotfiles.essential.enable =
    mkEnableOption "Essential packages for servers and desktops";

  config = mkIf config.programs.dotfiles.essential.enable {
    home.packages = with pkgs;
      [
        bat
        broot
        clang-tools
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
        tokei
        universal-ctags
        wget
        nodePackages.prettier
      ] ++ (with pkgs.gitAndTools; [ delta diff-so-fancy git-absorb ]);
  };
}
