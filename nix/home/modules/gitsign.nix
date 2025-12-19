{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.dotfiles.gitsign;

  inherit (config.home) homeDirectory;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  program = lib.getExe cfg.package;
  cacheDir = if isDarwin then "${homeDirectory}/Library/Caches" else config.xdg.cacheHome;
  socketPath = "${cacheDir}/sigstore/gitsign/cache.sock";
in
{
  options.dotfiles.gitsign = {
    enable = lib.mkEnableOption "Git signing with Sigstore";
    enableCredentialCache = lib.mkEnableOption "credential caching";
    package = lib.mkPackageOption pkgs "gitsign" { };
    settings = lib.mkOption {
      type = with lib.types; attrsOf anything;
      description = ''
        Settings for gitsign.

        <https://docs.sigstore.dev/cosign/signing/gitsign/#configuration>
      '';
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    dotfiles.git.config = {
      commit.gpgsign = lib.mkDefault true;
      tag.gpgsign = lib.mkDefault true;
      gpg = {
        format = "x509";
        x509.program = program;
      };
      gitsign = lib.mkIf (cfg.settings != { }) cfg.settings;
    };

    programs.jujutsu.settings = {
      git.sign-on-push = lib.mkDefault true;
      signing = {
        behavior = lib.mkDefault "drop";
        backend = "gpgsm";
        backends.gpgsm.program = program;
      };
    };

    home.sessionVariables.GITSIGN_CREDENTIAL_CACHE = lib.mkIf cfg.enableCredentialCache socketPath;

    systemd.user = lib.mkIf (cfg.enableCredentialCache && isLinux) {
      services.gitsign-credential-cache = {
        Unit = {
          Description = "Gitsign credential cache";
          Requires = "gitsign-credential-cache.socket";
          After = "gitsign-credential-cache.socket";
          RefuseManualStart = true;
        };
        Service.ExecStart = "${cfg.package}/bin/gitsign-credential-cache";
      };

      sockets.gpg-agent = {
        Unit.Description = "Gitsign credential cache socket";
        Socket = {
          ListenStream = socketPath;
          DirectoryMode = "0700";
        };
        Install.WantedBy = [ "default.target" ];
      };
    };

    launchd.agents.gitsign-credential-cache = lib.mkIf (cfg.enableCredentialCache && isDarwin) {
      enable = lib.mkDefault true;
      config = {
        KeepAlive = true;
        ProgramArguments = [ "${cfg.package}/bin/gitsign-credential-cache" ];
        RunAtLoad = true;
      };
    };
  };
}
