{ inputs }:

let
  inherit (inputs) self flake-utils home darwin nixpkgs nixos;
  inherit (home.lib) homeManagerConfiguration;
  inherit (darwin.lib) darwinSystem;
  inherit (nixpkgs.lib) importTOML mkDefault recursiveUpdate;
  inherit (nixos.lib) nixosSystem;

  nixpkgsArgs = {
    config = import ../home/files/.config/nixpkgs/config.nix;
    overlays = [ self.overlays.default ];
  };
in
rec {
  config = importTOML ../config.toml;

  supportedPlatforms = [
    "aarch64-darwin"
    "x86_64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];

  # Wrapper function for creating a Nixpkgs package set that includes the
  # dotfiles overlays and unfree packages.
  #
  # Example:
  #   mkPkgs nixpkgs { }
  #   mkPkgs { system = "x86_64-linux"; }
  #
  mkPkgs = pkgs:
    { system ? config.os.system
    , config ? { }
    , overlays ? [ ]
    , ...
    } @ args:
    import pkgs (args // {
      inherit system;
      config = nixpkgsArgs.config // config;
      overlays = nixpkgsArgs.overlays ++ overlays;
    });

  # Builds a map from attr=value to attr.system=value for each system. Based
  # upon eachSystem in flake-utils, this also provides the Nixpkgs and NixOS
  # package sets each system when iterating through it.
  #
  # Type: eachSystemPkgs :: [ System ] -> ({ system, pkgs, nixos } -> Attrs) -> Attrs
  #
  # Example:
  #   eachSystemPkgs [ "aarch64-linux" "x86_64-linux" ] ({ ... }:
  #     { white-album = 2; }
  #   )
  #   => {
  #        white-album = {
  #          aarch64-linux = 2;
  #          x86_64-linux = 2;
  #        };
  #      }
  #
  eachSystemPkgs = systems: f: flake-utils.lib.eachSystem systems (
    system:
    let
      pkgs = mkPkgs inputs.nixpkgs { inherit system; };
      nixos = mkPkgs inputs.nixos { inherit system; };
    in
    f { inherit system pkgs nixos; }
  );

  # eachSystem pre-populated with all Unix systems supported by Nixpkgs.
  #
  # Type: eachSupportedSystemPkgs :: (System -> Pkgs -> Attrs) -> Attrs
  #
  eachSupportedSystemPkgs = eachSystemPkgs supportedPlatforms;

  # Creates a Home Manager configuration with addtional modules. The interface
  # is identical to homeManagerConfiguration from Home Manager.
  #
  mkHome =
    { system ? config.os.system
    , pkgs ? mkPkgs nixpkgs { inherit system; }
    , modules ? [ ]
    , ...
    } @ args:
    let hmArgs = builtins.removeAttrs args [ "system" ];
    in
    homeManagerConfiguration (hmArgs // {
      inherit pkgs;
      modules = modules ++ [
        self.homeModules.default
        ({ lib, ... }: {
          home = {
            username = lib.mkDefault config.user.name;
            homeDirectory = lib.mkDefault config.user.homeDirectory;
            stateVersion = lib.mkDefault config.user.stateVersion;
          };
        })
      ];
    });

  # Creates a Home Manager configuration from the specified file. It calls into
  # mkHome under the hood.
  #
  importHome = configPath: args:
    mkHome (args // { modules = [ (import configPath) ]; });

  # Creates a nix-darwin configuration with addtional modules. The interface
  # is identical to darwinSystem from nix-darwin.
  #
  mkDarwin = { modules ? [ ], system ? config.os.darwin.system, ... } @ args:
    darwinSystem (args // {
      inherit system;
      modules = modules ++ [
        self.darwinModules.default
        home.darwinModules.default
        ({ lib, ... }:
          {
            system.stateVersion = lib.mkDefault config.os.darwin.stateVersion;
            nixpkgs = nixpkgsArgs;
            home-manager = {
              useGlobalPkgs = true;
              sharedModules = [
                self.homeModules.default
                { home.stateVersion = lib.mkDefault config.user.stateVersion; }
              ];
            };
          })
      ];
    });

  # Creates a nix-darwin configuration from the specified file. It calls into
  # mkDarwin under the hood.
  #
  importDarwin = configPath: args:
    mkDarwin (args // { modules = [ (import configPath) ]; });

  # Creates a NixOS configuration with addtional modules. The interface is
  # identical to nixosSystem from NixOS.
  #
  mkNixOS =
    { modules ? [ ]
    , system ? config.os.system
    , ...
    } @ args:
    nixosSystem (args // {
      inherit system;
      modules = modules ++ [
        self.nixosModules.default
        ({ lib, ... }:
          {
            system.stateVersion = lib.mkDefault config.os.stateVersion;
            nixpkgs = nixpkgsArgs;
          })
      ];
    });

  # Creates a NixOS configuration from the specified file. It calls into mkNixOS
  # under the hood.
  #
  importNixOS = configPath: args:
    mkNixOS (args // { modules = [ (import configPath) ]; });

  # Sets hardening options for systemd services.
  #
  hardenSystemdService = args:
    recursiveUpdate args {
      serviceConfig = {
        # this enables the following options:
        #  - PrivateTmp       = true
        #  - RemoveIPC        = true
        #  - NoNewPrivileges  = true
        #  - RestrictSUIDSGID = true
        #  - ProtectSystem    = strict
        #  - ProtectHome      = read-only
        DynamicUser = mkDefault true;

        PrivateDevices = mkDefault true;
        PrivateUsers = mkDefault true;
        ProtectHostname = mkDefault true;
        ProtectClock = mkDefault true;
        ProtectProc = mkDefault "invisible";
        ProtectKernelTunables = mkDefault true;
        ProtectKernelModules = mkDefault true;
        ProtectKernelLogs = mkDefault true;
        ProtectControlGroups = mkDefault true;
        RestrictNamespaces = mkDefault true;
        LockPersonality = mkDefault true;
        MemoryDenyWriteExecute = mkDefault true;
        RestrictRealtime = mkDefault true;
        SystemCallFilter = mkDefault [ "@system-service" "~@mount" ];
      };
    };
}
