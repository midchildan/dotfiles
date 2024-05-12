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

  mapPrioritizedAttrsToList =
    mapFn: compareFn: attrs:
    let
      nameValueFor = name: lib.nameValuePair name attrs.${name};
      compareNames = name1: name2: compareFn (nameValueFor name1) (nameValueFor name2);
      names = lib.sort compareNames (lib.attrNames attrs);
    in
    map (name: mapFn name attrs.${name}) names;
in
{
  flake.lib = {
    inherit hardenSystemdService indexOf mapPrioritizedAttrsToList;
  };
}
