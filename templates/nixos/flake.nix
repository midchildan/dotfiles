{
  description = "NixOS configuration";

  inputs = {
    dotfiles.url = "github:midchildan/dotfiles";

    # NOTE: workaround for https://github.com/NixOS/nix/pull/4641
    #
    # this shouldn't be necesary after the fix is released
    nixpkgs.follows = "dotfiles/nixpkgs";
  };

  outputs = { dotfiles, ... }: {
    nixosConfigurations.my-desktop = dotfiles.lib.mkNixOS {
      modules = [{
        # See list of options in:
        # https://github.com/midchildan/dotfiles/blob/master/docs/nix.md
        dotfiles.profiles = {
          hardware.enable = true;
          interactive.enable = true;
          network.enable = true;
          desktop.enable = true;
        };
      }];
    };
  };
}
