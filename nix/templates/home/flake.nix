{
  description = "Home Manager configuration";

  inputs = {
    dotfiles.url = "github:midchildan/dotfiles";

    # NOTE: workaround for https://github.com/NixOS/nix/pull/4641
    #
    # this shouldn't be necesary after the fix is released
    nixpkgs.follows = "dotfiles/nixpkgs";
  };

  outputs = { dotfiles, ... }: {
    homeManagerConfigurations.my-desktop = dotfiles.lib.mkHome {
      username = "midchildan";
      homeDirectory = "/home/midchildan";
      system = "x86_64-linux";
      configuration = {
        # See list of options in:
        # https://github.com/midchildan/dotfiles/blob/main/docs/nix.md
        dotfiles.profiles.enableAll = true;
      };
    };
  };
}
