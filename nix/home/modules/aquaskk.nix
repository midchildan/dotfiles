{ config, lib, pkgs, dotfiles, ... }:

let
  cfg = config.dotfiles.aquaskk;
  dictTypes = [ "euc-jp" "online" "skkserv" "kotoeri" "program" "utf-8" ];

  inherit (pkgs.stdenv.hostPlatform) system;
  myPkgs = dotfiles.packages.${system};

  dictionarySet = lib.mapAttrsToList
    (name: config: {
      inherit (config) active location;
      type =
        let
          index = dotfiles.lib.indexOf config.type dictTypes;
          option = "dotfiles.aquaskk.dictionaries.${name}";
          value = config.type;
        in
        if index >= 0 then index
        else throw "Option '${option}' has unknown value '${value}'.";
    })
    cfg.dictionaries;
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
      type = with lib.types; attrsOf (submodule ({ name, ... }: {
        options = {
          active = lib.mkOption {
            type = bool;
            default = true;
            description = "Whether to enable the dictionary \"${name}\".";
          };
          location = lib.mkOption {
            type = str;
            default = name;
            description = "Location of the dictionary \"${name}\".";
          };
          type = lib.mkOption {
            type = enum dictTypes;
            description = "Type of the dictionary \"${name}\".";
          };
        };
      }));

      default = {
        "SKK-JISYO.L" = {
          location = "${myPkgs.skk-jisyo-l}/share/skk/SKK-JISYO.L";
          type = "euc-jp";
        };
      };

      example = {
        "~/.skk-jisyo".type = "euc-jp";
        "SKK-JISYO.L".type = "online";
      };

      description = ''
        Dictionaries to use for SKK conversion.

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
    assertions = [
      (lib.hm.assertions.assertPlatform "dotfiles.aquaskk" pkgs
        lib.platforms.darwin)
    ];

    targets.darwin.defaults = {
      "jp.sourceforge.inputmethod.aquaskk.plist" = cfg.config;
    };

    home.file."Library/Application Support/AquaSKK/DictionarySet.plist" =
      lib.mkIf (cfg.dictionaries != { }) {
        text = lib.generators.toPlist { } dictionarySet;
        force = true;
      };
  };
}
