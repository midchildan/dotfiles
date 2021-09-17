{ inputs }:

let
  inherit (inputs) self flake-utils home darwin nixpkgs nixos;
  inherit (home.lib) homeManagerConfiguration;
  inherit (darwin.lib) darwinSystem;
  inherit (nixpkgs.lib) mkDefault recursiveUpdate;
  inherit (nixos.lib) nixosSystem;
in
rec {
  config = builtins.fromTOML (builtins.readFile ../config.toml);

  supportedPlatforms = [
    "aarch64-darwin"
    "x86_64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];

  # Creates a Nixpkgs instance with unfree packages for the specified system
  #
  # Example:
  #   mkPkgs nixpkgs { }
  #   mkPkgs { system = "x86_64-linux"; }
  #
  mkPkgs = pkgs: { system ? config.os.system }:
    import pkgs {
      inherit system;
      config.allowUnfree = true;
    };

  # Builds a map from attr=value to attr.system=value for each system. Based
  # upon eachSystem in flake-utils, this also provides the Nixpkgs instance for
  # each system when iterating through it.
  #
  # Type: eachSystemPkgs :: [ System ] -> (System -> Pkgs -> Attrs) -> Attrs
  #
  # Example:
  #   eachSystemPkgs [ "aarch64-linux" "x86_64-linux" ] (system: pkgs:
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
    let pkgs = mkPkgs nixpkgs { inherit system; }; in
    f system pkgs
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
    { configuration
    , username ? config.user.name
    , homeDirectory ? config.user.homeDirectory
    , system ? config.os.system
    , stateVersion ? config.user.stateVersion
    , extraModules ? [ ]
    , pkgs ? mkPkgs nixpkgs { inherit system; }
    , ...
    } @ args:
    homeManagerConfiguration (args // {
      inherit username homeDirectory system stateVersion pkgs;
      extraModules = [ self.homeModule ] ++ extraModules;
    });

  # Creates a Home Manager configuration from the specified file. It calls into
  # mkHome under the hood.
  #
  importHome = configPath: args:
    mkHome (args // { configuration = import configPath; });

  # Creates a nix-darwin configuration with addtional modules. The interface
  # is identical to darwinSystem from nix-darwin.
  #
  mkDarwin = { modules ? [ ], system ? config.os.darwin.system, ... } @ args:
    darwinSystem (args // {
      inherit system;
      modules = modules ++ [
        self.darwinModule
        home.darwinModule
        {
          system.stateVersion = config.os.darwin.stateVersion;
          home-manager = {
            useGlobalPkgs = true;
            sharedModules = [
              self.homeModule
              { home.stateVersion = config.user.stateVersion; }
            ];
          };
        }
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
        self.nixosModule
        home.nixosModule
        {
          system.stateVersion = config.os.stateVersion;
          home-manager = {
            sharedModules = [
              self.homeModule
              {
                home.stateVersion = config.user.stateVersion;
                nixpkgs.config.allowUnfree = true;
              }
            ];
          };
        }
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
