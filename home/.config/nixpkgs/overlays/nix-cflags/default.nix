self: super: {
  nix-cflags =
    let
      stdenv = super.stdenv;
      lib = super.lib;

      libc = lib.getDev stdenv.cc.libc;
      libcxx = super.llvmPackages.libcxx;
      clang = super.llvmPackages.clang-unwrapped;
    in
      super.stdenv.mkDerivation {
        name = "nix-cflags";

        phases = [ "installPhase" "fixupPhase" ];
        buildInputs = [ libc libcxx clang ];

        installPhase = ''
          mkdir -p $out/bin
          substitute "${./nix-cflags}" $out/bin/nix-cflags \
            --replace @libc@ "${libc}/include" \
            --replace @libcxx@ "${libcxx}/include/c++/v1" \
            --replace @clang@ "${clang}"
          chmod +x $out/bin/nix-cflags
        '';
      };
}
