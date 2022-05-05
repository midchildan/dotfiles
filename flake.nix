{
  description = "Dotfiles from Midchilda";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:NixOS/nixpkgs/nixos-21.11";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, home, ... } @ inputs:
    let lib = import ./lib { inherit inputs; }; in
    {
      inherit lib;

      overlay = import ./overlays { inherit inputs; };
      overlays = {
        nixpkgs = import ./overlays/nixpkgs.nix;
        nixos = import ./overlays/nixos.nix;
      };

      homeModule = import ./home { inherit inputs; };
      homeConfigurations = import ./home/machines { inherit inputs; };

      darwinModule = import ./darwin { inherit inputs; };
      darwinConfigurations = import ./darwin/machines { inherit inputs; };

      nixosModule = import ./nixos { inherit inputs; };
      nixosConfigurations = import ./nixos/machines { inherit inputs; };

      templates = {
        home = {
          path = ./templates/home;
          description = "Home Manager configuration";
        };
        darwin = {
          path = ./templates/darwin;
          description = "Nix-Darwin configuration";
        };
        nixos = {
          path = ./templates/nixos;
          description = "NixOS configuration";
        };
      };
    } // (lib.eachSupportedSystemPkgs ({ system, pkgs, nixos }:
      let
        packages = import ./packages { inherit inputs pkgs nixos; };
        devShell = pkgs.callPackage ./devshells/shell.nix { };
      in
      {
        inherit devShell packages;

        devShells = {
          dev = devShell;
          setup = pkgs.callPackage ./devshells/setup.nix {
            inherit (packages) neovim;
          };
          quic = pkgs.callPackage ./devshells/quic.nix { };
        };

        apps = {
          home = {
            type = "app";
            program = "${home.defaultPackage.${system}}/bin/home-manager";
          };
          update = {
            type = "app";
            program = "${pkgs.callPackage ./scripts/apps/update.nix { }}";
          };
        } // pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
          darwin = {
            type = "app";
            program = "${packages.nix-darwin}/bin/darwin-rebuild";
          };
        } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
          nixos = {
            type = "app";
            program = "${packages.nixos-rebuild}/bin/nixos-rebuild";
          };
        };
      }));
}
