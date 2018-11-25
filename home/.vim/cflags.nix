#!/usr/bin/env -S nix eval --raw -f

let
  pkgs = import <nixpkgs> { };
  stdenv = pkgs.stdenv;
  lib = pkgs.lib;

  enableCXX = true;

  libc = lib.getDev stdenv.cc.libc;
  libcxx = pkgs.llvmPackages.libcxx;

  nixflags = lib.splitString " " (builtins.getEnv "NIX_CFLAGS_COMPILE");
  cflags = [ "-isystem" "${libc}/include" ];
  cxxflags = if enableCXX
             then [ "-isystem" "${libcxx}/include/c++/v1" ]
             else [];

  compileFlags = cflags ++ cxxflags ++ (lib.remove "" nixflags);
in
  builtins.concatStringsSep "\n" compileFlags
