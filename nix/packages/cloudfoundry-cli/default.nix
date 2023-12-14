# Some parts of this file are reused from the Nixpkgs project
# https://github.com/NixOS/nixpkgs/blob/ae367fc/pkgs/applications/networking/cluster/cloudfoundry-cli/default.nix
#
# License for the reused parts:
#
# Copyright (c) 2003-2022 Eelco Dolstra and the Nixpkgs/NixOS contributors
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

{ lib
, fetchFromGitHub
, applyPatches
, buildGoModule
, fetchurl
, installShellFiles
}:

buildGoModule rec {
  pname = "cloudfoundry-cli-6";
  version = "6.53.0";

  # Use applyPatches rather than patching it inside buildGoModule because it's
  # more convenient to have cloudfoundry-cli-6.src evaluate to the patched code
  # when making further changes to go.mod & go.sum.
  src = applyPatches {
    src = fetchFromGitHub ({
      owner = "cloudfoundry";
      repo = "cli";
      rev = "v${version}";
      fetchSubmodules = false;
      sha256 = "sha256-1IFufrKZvKlbgyoItOnapNCOTWqvV62BH+3q8d1oMtw=";
    });

    patches = [ ./bump-go-loggregator.patch ];

    postPatch = ''
      cp ${./.}/go.{mod,sum} .
      rm -rf Gopkg.toml Gopkg.lock vendor
    '';
  };

  vendorHash = "sha256-02hGaIaWx5EIYQAl6MVy04VvnBtzH1ge9X2R+plkD5A=";
  subPackages = [ "." ];

  # upstream have helpfully moved the bash completion script to a separate
  # repo which receives no releases or even tags
  bashCompletionScript = fetchurl {
    url = "https://raw.githubusercontent.com/cloudfoundry/cli-ci/5891ac019ff0d838b75acf45d02b5345ef21839d/ci/installers/completion/cf";
    sha256 = "1vhg9jcgaxcvvb4pqnhkf27b3qivs4d3w232j0gbh9393m3qxrvy";
  };

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-s"
    "-w"
    "-X code.cloudfoundry.org/cli/version.binaryBuildDate=1970-01-01"
    "-X code.cloudfoundry.org/cli/version.binaryVersion=${version}"
  ];

  postInstall = ''
    mv "$out/bin/cli" "$out/bin/cf"
    installShellCompletion --bash $bashCompletionScript
  '';

  meta = {
    description = "The official command line client for Cloud Foundry";
    longDescription = ''
      Version 6 of the Cloud Foundry CLI that supports CAPI v2. For differences
      with later version of the CLI, see the below link for details:

      https://docs.cloudfoundry.org/cf-cli/v7.html
    '';
    homepage = "https://github.com/cloudfoundry/cli";
    license = lib.licenses.asl20;
  };
}
