{ config, lib, pkgs, ... }:

let
  cfg = config.dotfiles.firefox;

  inherit (pkgs.stdenv) isDarwin;

  defaultPackage = if isDarwin then null else pkgs.firefox-bin;
  finalPackage = cfg.package.override {
    extraPolicies = cfg.policies;
  };
in
{
  options.dotfiles.firefox = {
    enable = lib.mkEnableOption "Firefox";
    package = lib.mkOption {
      type = with lib.types; nullOr package;
      default = defaultPackage;
      description = ''
        The Firefox package to use. If <literal>null</literal>, it is assumed
        that Firefox is installed outside of Nix.
      '';
    };
    policies = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      description = ''
        Configure firefox enterprise policies. On platforms other than macOS,
        this option requires the the <option>package</option> option to be a
        non <literal>null</literal> value in order for it to work.

        See <link xlink:href="https://github.com/mozilla/policy-templates/blob/master/README.md"/>
        for a list of available options.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional (cfg.package != null) finalPackage;

    targets.darwin.defaults = lib.mkIf (isDarwin && cfg.package == null) {
      "org.mozilla.firefox" = cfg.policies // {
        EnterprisePoliciesEnabled = true;
      };
    };
  };
}
