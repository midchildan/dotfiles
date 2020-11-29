{ config, lib, pkgs, ... }:

with lib;

let inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  options.programs.dotfiles.essential.enable =
    mkEnableOption "Essential packages for servers and desktops alike";

  config = mkIf config.programs.dotfiles.essential.enable {
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
        nixfmt
        nkf
        nyancat
        p7zip
        ranger
        tig
        tmux
        wget
        nodePackages.prettier
      ] ++ optionals (!isDarwin) [ dnsutils file git netcat whois ]
      ++ (with pkgs.gitAndTools; [ delta diff-so-fancy git-absorb ]);
  };
}
