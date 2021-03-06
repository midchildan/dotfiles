{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  extraPkgs = import ../pkgs { inherit pkgs; };
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
        nixfmt
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
        extraPkgs.terminfo-collection
      ] ++ optional isDarwin watch;
  };
}
