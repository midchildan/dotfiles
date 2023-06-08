{
  description = "Dotfiles from Midchilda";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
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

      overlays = import ./nix/overlays { inherit inputs; };
      templates = import ./nix/templates;

      homeModules.default = import ./nix/home { inherit inputs; };
      homeConfigurations = import ./nix/home/machines { inherit inputs; };

      darwinModules.default = import ./nix/darwin { inherit inputs; };
      darwinConfigurations = import ./nix/darwin/machines { inherit inputs; };

      nixosModules.default = import ./nix/nixos { inherit inputs; };
      nixosConfigurations = import ./nix/nixos/machines { inherit inputs; };

    } // (lib.eachSupportedSystemPkgs ({ system, pkgs, nixos }:

      let
        formatter = pkgs.nixpkgs-fmt;
        packages = import ./nix/packages { inherit inputs pkgs nixos; };
      in
      {
        inherit packages formatter;

        apps = import ./nix/apps { inherit inputs pkgs system packages; };
        devShells = import ./nix/devshells { inherit pkgs formatter packages; };
      }));
}
