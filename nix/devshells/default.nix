{ pkgs
, formatter
, packages
}:

{
  default = pkgs.callPackage ./shell.nix {
    inherit formatter;
  };

  setup = pkgs.callPackage ./setup.nix {
    inherit (packages) neovim;
  };

  quic = pkgs.callPackage ./quic.nix { };
}
