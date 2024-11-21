{
  lib,
  config,
  ...
}:

{
  config = lib.mkIf config.dotfiles.profiles.macos.enable {
    dotfiles.iterm2.profiles.home-manager = (import ./gruvbox.nix) // {
      # General
      "Name" = "Home Manager";
      "Description" = "Configured with Home Manager";
      "Guid" = "55297699-7282-4EB9-9ED5-1F979084658F";
      "Shortcut" = "";
      "Tags" = [ ];
      "Icon" = 1;
      "Command" = "";
      "Custom Command" = "No";
      "Working Directory" = config.home.homeDirectory;
      "Custom Directory" = "Advanced";
      "AWDS Window Option" = "No";
      "AWDS Window Directory" = "";
      "AWDS Tab Option" = "Recycle";
      "AWDS Tab Directory" = "";
      "AWDS Pane Option" = "Recycle";
      "AWDS Pane Directory" = "";
      # Colors
      "Use Separate Colors for Light and Dark Mode" = false;
      # Text
      "Blinking Cursor" = false;
      "Use Bold Font" = true;
      "Use Italic Font" = true;
      "Draw Powerline Glyphs" = false;
      "Ambiguous Double Width" = false;
      "Normal Font" = "FiraCodeRoman-Regular 12";
      "Horizontal Spacing" = 1;
      "Vertical Spacing" = 1;
      "ASCII Anti Aliased" = true;
      "Use Non-ASCII Font" = true;
      "Non Ascii Font" = "FiraCodeRoman-Regular 12";
      "Non-ASCII Anti Aliased" = true;
      "Special Font Config" = {
        entries = [
          # Avoid overriding Fira Code symbols
          {
            start = 57344;
            count = 11;
            fontName = "Symbols Nerd Font Mono";
          }
          {
            start = 57507;
            count = 1;
            fontName = "Symbols Nerd Font Mono";
          }
          {
            start = 57524;
            count = 3404;
            fontName = "Symbols Nerd Font Mono";
          }
          {
            start = 60940;
            count = 2804;
            fontName = "Symbols Nerd Font Mono";
          }
          {
            count = 65536;
            start = 983040;
            fontName = "Symbols Nerd Font Mono";
          }
        ];
        version = 1;
      };
      # Window
      "Transparency" = 0;
      "Blur" = false;
      "Background Image Location" = "";
      "Columns" = 132;
      "Rows" = 43;
      "Window Type" = 0;
      "Screen" = -1;
      # Terminal
      "Scrollback Lines" = 10000;
      "Unlimited Scrollback" = false;
      "Scrollback in Alternate Screen" = false;
      "Character Encoding" = 4; # Unicode (UTF-8)
      "Terminal Type" = "xterm-256color";
      "Mouse Reporting" = true;
      "Sync Title" = false;
      "Disable Window Resizing" = true;
      "Silence Bell" = false;
      "BM Growl" = true;
      "Flashing Bell" = false;
      "Visual Bell" = true;
      "Set Local Environment Vars" = false;
      # Session
      "Close Sessions On End" = true;
      "Prompt Before Closing 2" = 2;
      "Jobs to Ignore" = [
        "rlogin"
        "ssh"
        "slogin"
        "telnet"
      ];
      "Send Code When Idle" = false;
      "Idle Code" = 0;
      # Keys
      "Option Key Sends" = 2;
      "Right Option Key Sends" = 2;
      "Has Hotkey" = false;
      # Advanced
      "Bound Hosts" = [ ];
      # I have no idea what this is
      "Default Bookmark" = "No";
    };
  };
}
