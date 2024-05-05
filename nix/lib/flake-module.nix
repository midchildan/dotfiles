{ inputs }@localFlake:
{
  lib,
  config,
  getSystem,
  ...
}@flake:

let
  inherit (localFlake.inputs.home.lib) homeManagerConfiguration;
  inherit (localFlake.inputs.darwin.lib) darwinSystem;
  inherit (localFlake.inputs.nixos.lib) nixosSystem;

  cfg = config.dotfiles;

  # Creates a Home Manager configuration with addtional modules. The interface
  # is identical to homeManagerConfiguration from Home Manager.
  #
  mkHome =
    {
      pkgs,
      modules ? [ ],
      ...
    }@args:
    let
      userDir = if pkgs.stdenv.isDarwin then "/Users" else "/home";
      flakeOptionsModule =
        { lib, config, ... }:
        {
          dotfiles._flakeOptions = flake.config.dotfiles;
          home = {
            username = lib.mkDefault config.dotfiles._flakeOptions.user.name;
            homeDirectory = lib.mkDefault "${userDir}/${config.home.username}";
          };
        };
    in
    homeManagerConfiguration (
      args
      // {
        inherit pkgs;
        modules =
          modules
          ++ cfg.home.modules
          ++ [
            localFlake.inputs.self.homeModules.default
            flakeOptionsModule
          ];
      }
    );

  # Creates a Home Manager configuration from the specified file. It calls into
  # mkHome under the hood.
  #
  importHome = configPath: args: mkHome (args // { modules = [ (import configPath) ]; });

  # Creates a nix-darwin configuration with addtional modules. The interface
  # is identical to darwinSystem from nix-darwin.
  #
  mkDarwin =
    {
      pkgs,
      modules ? [ ],
      ...
    }@args:
    let
      flakeOptionsModule = {
        dotfiles._flakeOptions = config.dotfiles;
        home-manager = {
          useGlobalPkgs = true;
          sharedModules = cfg.home.modules ++ [
            localFlake.inputs.self.homeModules.default
            { dotfiles._flakeOptions = config.dotfiles; }
          ];
        };
      };
    in
    darwinSystem (
      args
      // {
        inherit pkgs;
        modules =
          modules
          ++ cfg.darwin.modules
          ++ [
            localFlake.inputs.self.darwinModules.default
            localFlake.inputs.home.darwinModules.default
            flakeOptionsModule
          ];
      }
    );

  # Creates a nix-darwin configuration from the specified file. It calls into
  # mkDarwin under the hood.
  #
  importDarwin = configPath: args: mkDarwin (args // { modules = [ (import configPath) ]; });

  # Creates a NixOS configuration with addtional modules. The interface is
  # identical to nixosSystem from NixOS.
  #
  mkNixOS =
    {
      pkgs,
      modules ? [ ],
      ...
    }@args:
    nixosSystem (
      args
      // {
        inherit pkgs;
        modules =
          modules
          ++ cfg.nixos.modules
          ++ [
            localFlake.inputs.self.nixosModules.default
            { dotfiles._flakeOptions = config.dotfiles; }
          ];
      }
    );

  # Creates a NixOS configuration from the specified file. It calls into mkNixOS
  # under the hood.
  #
  importNixOS = configPath: args: mkNixOS (args // { modules = [ (import configPath) ]; });

  # Instantiates Nixpkgs for the given architecture.
  #
  pkgsFor = system: (getSystem system).allModuleArgs.pkgs;

  # Instantiates stable Nixpkgs for the given architecture.
  #
  nixosFor = system: (getSystem system).allModuleArgs.nixos;
in
{
  # Allow downstream flakes to define additional things under lib.
  #
  options.flake.lib = lib.mkOption { type = with lib.types; lazyAttrsOf raw; };

  config.flake.lib = {
    inherit
      mkHome
      importHome
      mkDarwin
      importDarwin
      mkNixOS
      importNixOS
      pkgsFor
      nixosFor
      ;
  };
}
