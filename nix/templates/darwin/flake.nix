{
  description = "Darwin configuration";

  inputs = {
    dotfiles.url = "github:midchildan/dotfiles";

    # NOTE: workaround for https://github.com/NixOS/nix/pull/4641
    #
    # this shouldn't be necesary after the fix is released
    nixpkgs.follows = "dotfiles/nixpkgs";
  };

  outputs = { dotfiles, ... }:
    let
      username = dotfiles.lib.config.user.name;
    in
    {
      darwinConfigurations.my-macbook = dotfiles.lib.mkDarwin {
        modules = [{
          users.users.${username}.home = "/Users/${username}";

          # See list of options in:
          # https://github.com/midchildan/dotfiles/blob/main/docs/nix.md
          dotfiles.profiles.apps.enable = true;

          home-manager.users.${username} = {
            dotfiles.profiles.enableAll = true;
          };
        }];
      };
    };
}
