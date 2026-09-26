{ nixos-rebuild, nix }:

let
  nixos-rebuild' = nixos-rebuild.override { inherit nix; };
in
nixos-rebuild'.overrideAttrs (old: {
  passthru = (old.passthru or { }) // {
    updateScript = null;
  };
})
