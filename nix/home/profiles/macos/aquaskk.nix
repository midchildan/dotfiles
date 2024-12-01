{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.dotfiles.profiles.macos.enable {
    targets.darwin.defaults."com.apple.inputsources".AppleEnabledThirdPartyInputSources = [
      {
        "Bundle ID" = "jp.sourceforge.inputmethod.aquaskk";
        "Input Mode" = "com.apple.inputmethod.Japanese.Hiragana";
        InputSourceKind = "Input Mode";
      }
      {
        "Bundle ID" = "jp.sourceforge.inputmethod.aquaskk";
        InputSourceKind = "Keyboard Input Method";
      }
      {
        "Bundle ID" = "jp.sourceforge.inputmethod.aquaskk";
        "Input Method" = "com.apple.inputmethod.Roman";
        InputSourceKind = "Input Mode";
      }
    ];

    dotfiles.aquaskk = {
      enable = lib.mkDefault true;
      config = {
        beep_on_registration = lib.mkDefault false;
        enable_annotation = lib.mkDefault true;
        enable_dynamic_completion = lib.mkDefault true;
        enable_extended_completion = lib.mkDefault true;
        show_input_mode_icon = lib.mkDefault true;
      };
      dictionaries = {
        "SKK-JISYO.L" = {
          type = "euc-jp";
          priority = 70;
          location = "${pkgs.skkDictionaries.l}/share/skk/SKK-JISYO.L";
        };
        "SKK-JISYO.propernoun" = {
          type = "euc-jp";
          location = "${pkgs.skkDictionaries.propernoun}/share/skk/SKK-JISYO.propernoun";
        };
        "SKK-JISYO.zipcode" = {
          type = "euc-jp";
          location = "${pkgs.skkDictionaries.zipcode}/share/skk/SKK-JISYO.zipcode";
        };
        "SKK-JISYO.office.zipcode" = {
          type = "euc-jp";
          location = "${pkgs.skkDictionaries.zipcode}/share/skk/SKK-JISYO.office.zipcode";
        };
        "SKK-JISYO.emoji" = {
          type = "utf-8";
          priority = 30;
          location = "${pkgs.skkDictionaries.emoji}/share/skk/SKK-JISYO.emoji";
        };
        program.type = "program";
      };
    };
  };
}
