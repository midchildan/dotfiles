{ config, lib, pkgs, ... }:

with lib;

let inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  options.profiles.essential.enable =
    mkEnableOption "Essential packages for servers and desktops alike";

  config = mkIf config.profiles.essential.enable {
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
        zsh-completions
        nodePackages.prettier
      ] ++ (with pkgs.gitAndTools; [ delta diff-so-fancy git-absorb ])
      ++ optionals (!isDarwin) [ dnsutils file git netcat whois ]
      ++ optional isDarwin watch;
  };
}
