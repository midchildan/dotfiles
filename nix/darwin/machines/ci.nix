{ config, ... }:

let
  username = config.dotfiles.flakeOptions.user.name;
in
{
  users.users.${username}.home = "/Users/${username}";

  dotfiles.profiles.apps.enable = true;

  home-manager.users.${username} = {
    dotfiles.profiles = {
      enableAll = true;
      extras.enable = false;
    };
  };
}
