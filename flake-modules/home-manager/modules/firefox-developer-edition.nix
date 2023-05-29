{ config, lib, pkgs, specialArgs, ... }:
  let
    inherit (specialArgs) isGui;
    inherit (pkgs.stdenv) isLinux;
  in lib.mkIf (isGui && isLinux) {
    # You need to run this command set this as the default web browser:
    # `xdg-settings set default-web-browser my-firefox.desktop`.
    # I tried to run it here, but it failed with exit code 2 which, according to the manpage, means it couldn't find a
    # file. I think this is because home-manager doesn't run as the current user so it can't find the .desktop file
    # linked below.
    repository.symlink.xdg.dataFile = {
      "applications/my-firefox.desktop".source = "firefox-developer-edition/my-firefox.desktop";
    };

    repository.symlink.home.file.".local/bin/my-firefox".source = "firefox-developer-edition/my-firefox";
  }
