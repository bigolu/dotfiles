{
  lib,
  pkgs,
  specialArgs,
  ...
}: let
  inherit (specialArgs) isGui;
  inherit (lib.attrsets) optionalAttrs;
in
  optionalAttrs isGui {
    home.packages = with pkgs; [
      # ncurses doesn't come with wezterm's terminfo so I need to use the one from my overlay.
      # Also macOS comes with a very old version of ncurses that doesn't have a terminfo entry
      # for tmux, tmux-256color, either.
      ncursesWithWezterm
    ];

    home.file = {
      # Since environment variables from the login shell don't get inherited by apps in macOS,
      # my terminal will use the system ncurses, which doesn't have an entry for wezterm. To
      # work around this, I have to put the wezterm terminfo in a place where the system ncurses
      # will find it.
      #
      # Wezterm also needs it when running in flatpak.
      ".terminfo" = {
        source = "${pkgs.ncursesWithWezterm}/share/terminfo/";
        recursive = true;
      };
    };

    repository.symlink.xdg.configFile = {
      "wezterm/wezterm.lua".source = "wezterm/wezterm.lua";
    };
  }
