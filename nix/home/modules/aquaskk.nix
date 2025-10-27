{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:

let
  cfg = config.dotfiles.aquaskk;

  inherit (lib) hm;
  inherit (pkgs.stdenv.hostPlatform) system;

  myPkgs = dotfiles.packages.${system};

  # This has to be in a specific order.
  # https://github.com/codefirst/aquaskk/blob/0e7a88f/platform/mac/src/server/SKKServer.mm#L56-L63
  dictTypes = [
    "euc-jp"
    "online"
    "skkserv"
    "kotoeri"
    "program"
    "utf-8"
  ];

  # Creates an entry for DictionarySet.plist from an item in cfg.dictionary.
  mkDictionary = name: config: {
    inherit (config) active location;
    type =
      let
        index = dotfiles.lib.indexOf config.type dictTypes;
        option = "dotfiles.aquaskk.dictionaries.${name}";
        value = config.type;
      in
      if index >= 0 then index else throw "Option '${option}' has unknown value '${value}'.";
  };

  dictionarySet = dotfiles.lib.mapPrioritizedAttrsToList mkDictionary (
    a: b: a.value.priority > b.value.priority
  ) cfg.dictionaries;
in
{
  options.dotfiles.aquaskk = {
    enable = lib.mkEnableOption "AquaSKK";

    config = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      description = ''
        Configuration for AquaSKK. See the list of available options
        [here](https://github.com/codefirst/aquaskk/blob/master/platform/mac/plist/UserDefaults.plist).
      '';
    };

    dictionaries = lib.mkOption {
      type =
        with lib.types;
        attrsOf (
          submodule (
            { name, config, ... }:
            {
              options = {
                active = lib.mkOption {
                  type = bool;
                  default = true;
                  description = "Whether to enable the dictionary \"${name}\".";
                };
                location = lib.mkOption {
                  type = str;
                  default = name;
                  description = ''
                    Location of the dictionary "${name}". This option will emptied if
                    {option}`type` is set to `program`.
                  '';
                };
                type = lib.mkOption {
                  type = enum dictTypes;
                  description = "Type of the dictionary \"${name}\".";
                };
                priority = lib.mkOption {
                  type = ints.between 0 99;
                  default = 50;
                  description = ''
                    Priority of the dicionary "${name}". Conversion candidates will
                    be sorted according to this value. Candidates from dictionaries
                    with higher priority will come first.
                  '';
                };
              };

              config = lib.mkIf (config.type == "program") { location = ""; };
            }
          )
        );

      default = { };

      example = lib.literalExpression ''
        {
          "~/.skk-jisyo" = {
            type = "euc-jp";
            priority = 70;
          };
          "SKK-JISYO.L" = {
            type = "euc-jp";
            location = "''${pkgs.skk-dicts}/share/SKK-JISYO.L";
          };
          program.type = "program";
        }
      '';

      description = ''
        Dictionaries to use for SKK conversion. Upstream documentation about
        this option can be found in Japanese at
        <https://aquaskk.osdn.jp/dictionary_settings.html>.

        Dictionaries of type `online` will be fetched from
        {option}`dotfiles.aquaskk.config.openlab_host`. The list of available
        dictionaries can be seen at <https://skk-dev.github.io/dict/>.

        ::: {.warning}
        This option will overwrite any previous configuration you may have set
        through the AquaSKK's preference dialog.
        :::

        ::: {.warning}
        As of 4.7.5, [AquaSKK downloads dictionaries of the `online` type over
        unverified HTTP connections][httpdict]. This means that the dictionaries
        can be tampered with in transit. The consequences can range from messed
        up SKK conversions to attempted attacks on any potential weaknesses in
        the dictionary parsing code.

        Prefer local dictionaries if malicious network operators are a concern.
        :::

        [httpdict]: https://github.com/codefirst/aquaskk/blob/4.7.5/src/engine/dictionary/SKKHttpDictionaryLoader.cpp#L59
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ (lib.hm.assertions.assertPlatform "dotfiles.aquaskk" pkgs lib.platforms.darwin) ];

    targets.darwin.defaults = {
      "jp.sourceforge.inputmethod.aquaskk.plist" = cfg.config;
    };

    home.file."Library/Application Support/AquaSKK/DictionarySet.plist" =
      lib.mkIf (cfg.dictionaries != { })
        {
          text = lib.generators.toPlist { escape = true; } dictionarySet;
          force = true;
        };

    home.activation.reloadAquaSKK = hm.dag.entryAfter [ "setDarwinDefaults" ] ''
      $VERBOSE_ECHO "Reloading AquaSKK configuration"
      ${myPkgs.aquaskk-reload-config}/bin/aquaskk-reload-config
    '';
  };
}
