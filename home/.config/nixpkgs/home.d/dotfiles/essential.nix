{ config, pkgs, ... }:

{
  options.programs.dotfiles.essential.enable = mkEnableOption
      "Essential packages for servers and desktops";

  config = mkIf config.programs.dotfiles.essential.enable {
    home.packages = with pkgs;
      [
        bat
        cmigemo
        clang-tools
        dnsutils
        file
        fd
        ghq
        git
        lsof
        nixfmt
        nyancat
        ranger
        tig
        tmux
        tokei
        universal-ctags
        wget
        youtube-dl
      ] ++ (with pkgs.gitAndTools; [ delta diff-so-fancy ]);
  };
}
