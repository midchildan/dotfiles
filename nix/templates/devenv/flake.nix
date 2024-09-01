{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, devenv-root, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          lib,
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          packages.default = pkgs.hello;

          devenv.shells.default = {
            devenv.root =
              let
                devenvRootFileContent = builtins.readFile devenv-root.outPath;
              in
              pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

            name = "my-project";

            imports = [
              # This is just like the imports in devenv.nix.
              # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
              # ./devenv-foo.nix
            ];

            # https://devenv.sh/reference/options/

            packages = [ config.packages.default ] ++ (lib.attrValues config.treefmt.build.programs);

            enterShell = ''
              hello
            '';

            processes.hello.exec = "hello";

            pre-commit = {
              excludes = [ ".*\\.lock$" ];
              hooks = {
                check-executables-have-shebangs.enable = true;
                editorconfig-checker.enable = true;
                treefmt = {
                  enable = true;
                  package = config.treefmt.build.wrapper;
                };
              };
            };

            stdenv = pkgs.stdenvNoCC; # C compilers aren't required for this project

            # the quickest way to make "nix flake check" pass
            containers = lib.mkIf (pkgs.stdenv.isDarwin) (lib.mkForce { });
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              prettier.enable = true;
              shellcheck.enable = true;
              shfmt = {
                enable = true;
                indent_size = null; # use settings fropm .editorconfig
              };
            };
            settings.formatter.shellcheck.options = [
              "--external-sources"
              "--source-path=SCRIPTDIR"
            ];
          };
        };

      flake = {
        # The usual flake attributes can be defined here, including system-agnostic ones like
        # nixosModule and system-enumerating ones, although those are more easily expressed in
        # perSystem.
      };
    };
}
