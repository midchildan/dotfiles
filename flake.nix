{
  description = "Dotfiles from Midchilda";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:NixOS/nixpkgs/nixos-22.11";
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
    let lib = import ./nix/lib { inherit inputs; }; in
    {
      inherit lib;

      overlays = {
        default = import ./nix/overlays { inherit inputs; };
        nixpkgs = import ./nix/overlays/nixpkgs.nix;
        nixos = import ./nix/overlays/nixos.nix;
      };

      homeModules.default = import ./nix/home { inherit inputs; };
      homeConfigurations = import ./nix/home/machines { inherit inputs; };

      darwinModules.default = import ./nix/darwin { inherit inputs; };
      darwinConfigurations = import ./nix/darwin/machines { inherit inputs; };

      nixosModules.default = import ./nix/nixos { inherit inputs; };
      nixosConfigurations = import ./nix/nixos/machines { inherit inputs; };

      templates = {
        home = {
          path = ./nix/templates/home;
          description = "Home Manager configuration";
        };
        darwin = {
          path = ./nix/templates/darwin;
          description = "Nix-Darwin configuration";
        };
        nixos = {
          path = ./nix/templates/nixos;
          description = "NixOS configuration";
        };
      };
    } // (lib.eachSupportedSystemPkgs ({ system, pkgs, nixos }:
      let
        formatter = pkgs.nixpkgs-fmt;
        packages = import ./nix/packages { inherit inputs pkgs nixos; };
        devShell = pkgs.callPackage ./nix/devshells/shell.nix {
          inherit formatter;
        };
      in
      {
        inherit packages formatter;

        devShells = {
          default = devShell;
          setup = pkgs.callPackage ./nix/devshells/setup.nix {
            inherit (packages) neovim;
          };
          quic = pkgs.callPackage ./nix/devshells/quic.nix { };
        };

        apps = {
          home = {
            type = "app";
            program = "${home.defaultPackage.${system}}/bin/home-manager";
          };
          update = {
            type = "app";
            program = "${pkgs.callPackage ./nix/apps/update.nix { }}";
          };
        } // pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
          os = {
            type = "app";
            program = "${packages.nix-darwin}/bin/darwin-rebuild";
          };
        } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
          os = {
            type = "app";
            program = "${packages.nixos-rebuild}/bin/nixos-rebuild";
          };
        };
      }));
}
