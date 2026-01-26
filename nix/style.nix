{ lib, inputs, ... }:

{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.pre-commit-hooks.flakeModule
  ];

  perSystem = {
    treefmt = {
      projectRootFile = lib.mkDefault "flake.nix";
      programs = {
        nixfmt.enable = lib.mkDefault true;
        shellcheck = {
          enable = lib.mkDefault true;
          external-sources = lib.mkDefault true;
          source-path = lib.mkDefault "SCRIPTDIR";
        };
        stylua.enable = lib.mkDefault true;
        prettier = {
          enable = lib.mkDefault true;
          settings.proseWrap = lib.mkDefault "always";
        };
      };
      settings.global.excludes = [
        # Prettier chokes on symlinks
        "files/.local/share/zsh/snippets/dotfiles/*.md"
      ];
    };

    pre-commit.settings.hooks = {
      check-executables-have-shebangs.enable = lib.mkDefault true;
      treefmt.enable = lib.mkDefault true;
    };
  };
}
