{ inputs }@localFlake:
{ lib, config, getSystem, ... }@flake:

let
  inherit (localFlake.inputs.home.lib) homeManagerConfiguration;
  inherit (localFlake.inputs.darwin.lib) darwinSystem;
  inherit (localFlake.inputs.nixos.lib) nixosSystem;

  cfg = config.dotfiles;

  # Creates a Home Manager configuration with addtional modules. The interface
  # is identical to homeManagerConfiguration from Home Manager.
  #
  mkHome = { pkgs, modules ? [ ], ... }@args:
    let
      userDir = if pkgs.stdenv.isDarwin then "/Users" else "/home";
      flakeOptionsModule = { lib, config, ... }: {
        dotfiles._flakeOptions = flake.config.dotfiles;
        home = {
          username = lib.mkDefault config.dotfiles._flakeOptions.user.name;
          homeDirectory = lib.mkDefault "${userDir}/${config.home.username}";
        };
      };
    in
    homeManagerConfiguration (args // {
      inherit pkgs;
      modules = modules ++ cfg.home.modules ++ [
        localFlake.inputs.self.homeModules.default
        flakeOptionsModule
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
  mkDarwin = { pkgs, modules ? [ ], ... }@args:
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
    darwinSystem (args // {
      inherit pkgs;
      modules = modules ++ cfg.darwin.modules ++ [
        localFlake.inputs.self.darwinModules.default
        localFlake.inputs.home.darwinModules.default
        flakeOptionsModule
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
  mkNixOS = { pkgs, modules ? [ ], ... }@args:
    nixosSystem (args // {
      inherit pkgs;
      modules = modules ++ cfg.nixos.modules ++ [
        localFlake.inputs.self.nixosModules.default
        { dotfiles._flakeOptions = config.dotfiles; }
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
    lib.recursiveUpdate args {
      serviceConfig = {
        # this enables the following options:
        #  - PrivateTmp       = true
        #  - RemoveIPC        = true
        #  - NoNewPrivileges  = true
        #  - RestrictSUIDSGID = true
        #  - ProtectSystem    = strict
        #  - ProtectHome      = read-only
        DynamicUser = lib.mkDefault true;

        PrivateDevices = lib.mkDefault true;
        PrivateUsers = lib.mkDefault true;
        ProtectHostname = lib.mkDefault true;
        ProtectClock = lib.mkDefault true;
        ProtectProc = lib.mkDefault "invisible";
        ProtectKernelTunables = lib.mkDefault true;
        ProtectKernelModules = lib.mkDefault true;
        ProtectKernelLogs = lib.mkDefault true;
        ProtectControlGroups = lib.mkDefault true;
        RestrictNamespaces = lib.mkDefault true;
        LockPersonality = lib.mkDefault true;
        MemoryDenyWriteExecute = lib.mkDefault true;
        RestrictRealtime = lib.mkDefault true;
        SystemCallFilter = lib.mkDefault [ "@system-service" "~@mount" ];
      };
    };

  indexOf = target: lib.foldl'
    (index: el:
      if index < 0 then
        if el == target then
          - index - 1
        else
          index - 1
      else
        index
    )
    (-1);

  mapPrioritizedAttrsToList = mapFn: compareFn: attrs:
    let
      nameValueFor = name: lib.nameValuePair name attrs.${name};
      compareNames = name1: name2:
        compareFn (nameValueFor name1) (nameValueFor name2);
      names = lib.sort compareNames (lib.attrNames attrs);
    in
    map (name: mapFn name attrs.${name}) names;
in
{
  flake.lib = {
    inherit mkHome importHome mkDarwin importDarwin mkNixOS importNixOS
      hardenSystemdService indexOf mapPrioritizedAttrsToList;
  };
}
