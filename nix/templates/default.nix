{
  flake.templates = {
    dotfiles = {
      path = ./dotfiles;
      description = "For Home Manager, NixOS, or Nix-Darwin.";
    };

    devenv = {
      path = ./devenv;
      description = "A devenv project.";
    };
  };
}
