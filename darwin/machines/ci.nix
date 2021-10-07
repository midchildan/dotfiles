{ dotfiles, ... }:

let
  username = dotfiles.lib.config.user.name;
  homeDirectory = dotfiles.lib.config.user.darwin.homeDirectory;
in
{
  users.users.${username}.home = homeDirectory;

  dotfiles.profiles.apps.enable = true;

  home-manager.users.${username} = {
    dotfiles.profiles = {
      enableAll = true;
      extras.enable = false;
    };
  };
}
