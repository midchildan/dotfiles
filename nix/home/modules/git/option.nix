{ lib, flakeOptions, ... }:

let
  hasSigningKey = flakeOptions.user.pgpKey != "";
in
{
  options = {
    commit.gpgsign = lib.mkOption {
      type = lib.types.bool;
      default = hasSigningKey;
      description = "Whether to sign commits.";
    };

    user = {
      name = lib.mkOption {
        type = lib.types.str;
        default = flakeOptions.user.fullName;
        description = "The name to use for the default git identity.";
      };

      email = lib.mkOption {
        type = lib.types.str;
        default = flakeOptions.user.email;
        description = "The email to use for the default git identity.";
      };
    };
  };

  config = lib.mkIf hasSigningKey { user.signingkey = flakeOptions.user.pgpKey; };
}
