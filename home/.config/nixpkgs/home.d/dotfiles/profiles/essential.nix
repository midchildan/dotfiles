{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  extraPkgs = import ../pkgs { inherit pkgs; };
in {
  options.dotfiles.profiles.essential.enable =
    mkEnableOption "Essential packages for servers and desktops alike";

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
        nixfmt
        nkf
        nyancat
        p7zip
        ranger
        ripgrep-all
        thefuck
        tig
        tmux
        wget
        zsh-completions
        nodePackages.prettier
      ] ++ (with pkgs.gitAndTools; [ delta diff-so-fancy git-absorb ])
      ++ optionals (!isDarwin) [
        dnsutils
        file
        git
        netcat
        whois
        extraPkgs.terminfo-collection
      ] ++ optional isDarwin watch;
  };
}
