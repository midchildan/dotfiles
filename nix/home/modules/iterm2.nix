{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.dotfiles.iterm2;
  json = pkgs.formats.json { };

  mkNullableOption =
    args:
    lib.mkOption (
      args
      // {
        type = lib.types.nullOr args.type;
        default = null;
      }
    );

  mkNullableEnableOption =
    name:
    lib.mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      example = true;
      description = "Whether to enable ${name}.";
    };
in
{
  options.dotfiles.iterm2 = {
    settings = lib.mkOption {
      description = "iTerm2 preferences.";
      default = { };
      type = lib.types.submodule {
        freeformType = with lib.types; attrsOf anything;
        options = {
          AddNewTabAtEndOfTabs = mkNullableEnableOption "placement of new tabs at the end of the tab bar";

          AlternateMouseScroll = mkNullableEnableOption "arrow keys when scrolling in alternate screen mode";

          CopySelection = mkNullableEnableOption "copy to clipboard upon selecting text";

          OpenTmuxWindowsIn = mkNullableOption {
            type = lib.types.int;
            example = 2;
            description = ''
              Configures how to restore tmux windows when attaching to a session.

              **Possible Values**

              `0`
              : Native windows

              `1`
              : Native tabs in a new window

              `2`
              : Tabs in the attaching window
            '';
          };

          ExperimentalKeyHandling = mkNullableEnableOption "experimental key handling for AquaSKK compatibility";
        };
      };
    };

    profiles = lib.mkOption {
      description = ''
        Defines iTerm2 Dynamic Profiles.

        See <https://iterm2.com/documentation-dynamic-profiles.html> for details.
      '';
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            freeformType = json.type;
            options = {
              Name = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Name of the profile.";
              };
              Description = lib.mkOption {
                type = lib.types.str;
                description = "Description of the profile.";
                default = "";
              };
              Guid = lib.mkOption {
                type = lib.types.str;
                description = ''
                  Globally unique identifier that can be used to track changes to the profile. No
                  two profiles should have the same guid.
                '';
              };
              "Special Font Config" = lib.mkOption {
                type = lib.types.submodule {
                  freeformType = json.type;
                };
                default = { };
                description = ''
                  Rules that maps a range of codes from another font into the terminal, possibly at
                  a different range. This option works when the non-ASCII font option is enabled.
                '';
                apply = builtins.toJSON;
              };
            };
          }
        )
      );
    };
  };

  config = {
    home.file."Library/Application Support/iTerm2/DynamicProfiles/home-manager.plist".text =
      builtins.toJSON
        { Profiles = lib.attrValues cfg.profiles; };

    targets.darwin.defaults."com.googlecode.iterm2" = cfg.settings;
  };
}
