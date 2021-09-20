{ lib, pkgs, dotfiles, ... }:

let
  inherit (dotfiles.lib) config;
  hasSigningKey = builtins.hasAttr "gpgKey" config;
in
{
  config = {
    xdg.configFile."git/user".text = lib.generators.toINI {} {
      commit.gpgsign = hasSigningKey;
      user = {
        name = config.user.name;
        email = config.user.email;
      } // lib.optionalAttrs hasSigningKey {
        signingkey = config.user.gpgKey;
      };
    };

    home.file.".gnupg/gpg.conf".source = pkgs.substituteAll {
      src = ../files/.gnupg/gpg.conf;
      inherit (config.user) gpgKey;
    };

    home.file.".vim/plugin/hmvars.vim".text = ''
      let g:snips_author = '${config.user.name}'
      let g:snips_email = '${config.user.email}'
      let g:snips_github = 'https://github.com/${config.user.name}'
    '';
  };
}