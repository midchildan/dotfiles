# overlay for the nixpkgs input to this flake

final: prev:

let
  # file 5.46 fails to detect zip files
  # https://bugs.astron.com/view.php?id=622
  # https://github.com/NixOS/nixpkgs/pull/402318
  file = prev.file.overrideAttrs (old: rec {
    version = "5.45";
    src = old.src.overrideAttrs {
      outputHash = "sha256-/Jf1ECm7DiyfTjv/79r2ePDgOe6HK53lwAKm0Jx4TYI=";
    };
  });
in
{
  zathuraPkgs = prev.zathuraPkgs.overrideScope (
    zfinal: zprev: {
      zathura_core = zprev.zathura_core.override {
        inherit file;
      };
    }
  );
}
