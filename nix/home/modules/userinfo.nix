{ lib, dotfiles, ... }:

let
  inherit (dotfiles.lib) config;
  hasSigningKey = lib.hasAttr "gpgKey" config.user;
in
{
  config = {
    dotfiles.git.config = {
      commit.gpgsign = hasSigningKey;
      user = {
        name = config.user.fullName;
        email = config.user.email;
      } // lib.optionalAttrs hasSigningKey {
        signingkey = config.user.gpgKey;
      };
    };

    home.file.".vim/plugin/hmvars.vim".text = ''
      let g:snips_author = '${config.user.name}'
      let g:snips_email = '${config.user.email}'
      let g:snips_github = 'https://github.com/${config.user.name}'
    '';
  };
}
