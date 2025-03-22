{ lib, ... }:

let
  # Sets hardening options for systemd services.
  #
  hardenSystemdService =
    args:
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
        SystemCallFilter = lib.mkDefault [
          "@system-service"
          "~@mount"
        ];
      };
    };

  indexOf =
    target:
    lib.foldl' (
      index: el: if index < 0 then if el == target then -index - 1 else index - 1 else index
    ) (-1);

  flatMapAttrs =
    f: attrs:
    lib.foldlAttrs (
      acc: name: value:
      lib.warnIf (lib.hasAttr name acc) "flatMapAttrs: conflicting definitions for attribute ${name}" acc
      // f name value
    ) { } attrs;

  flattenAttrs = flatMapAttrs (
    name: value: if lib.isDerivation value || !lib.isAttrs value then { ${name} = value; } else value
  );

  filterNonDrvAttrsRecursive =
    predicate:
    flatMapAttrs (
      name: value:
      lib.optionalAttrs (predicate name value) {
        "${name}" =
          if (lib.isAttrs value && !lib.isDerivation value) then
            filterNonDrvAttrsRecursive predicate value
          else
            value;
      }
    );

  mapPrioritizedAttrsToList =
    mapFn: compareFn: attrs:
    let
      nameValueFor = name: lib.nameValuePair name attrs.${name};
      compareNames = name1: name2: compareFn (nameValueFor name1) (nameValueFor name2);
      names = lib.sort compareNames (lib.attrNames attrs);
    in
    map (name: mapFn name attrs.${name}) names;

  collectLegacyPackages =
    attrs@{ pkgs, ... }:
    packagesFn:
    let
      autoCalledPkgs =
        self:
        lib.packagesFromDirectoryRecursive (
          { inherit (self) callPackage; } // lib.removeAttrs attrs [ "pkgs" ]
        );

      packagesFn' = self: { callPackages = lib.callPackagesWith (pkgs // self); } // packagesFn self;

      overlay = lib.flip (_: packagesFn');

      isAvailable =
        drv:
        lib.any (pred: pred drv) [
          (lib.meta.availableOn { inherit (pkgs.stdenv.hostPlatform) system; })
          (drv: !lib.isDerivation drv)
        ];

      allPackages = lib.makeScope pkgs.newScope (lib.extends overlay autoCalledPkgs);
    in
    filterNonDrvAttrsRecursive (_: isAvailable) allPackages;

  collectPackages =
    attrs: packagesFn:
    let
      allPackages = collectLegacyPackages attrs packagesFn;
    in
    lib.filterAttrs (_: lib.isDerivation) (flattenAttrs allPackages);

  importDir = dir: lib.mapAttrsToList (path: _: lib.path.append dir path) (builtins.readDir dir);

  importDirs = lib.concatMap importDir;
in
{
  flake.lib = {
    inherit
      hardenSystemdService
      indexOf
      flatMapAttrs
      flattenAttrs
      filterNonDrvAttrsRecursive
      mapPrioritizedAttrsToList
      collectLegacyPackages
      collectPackages
      importDir
      importDirs
      ;
  };
}
