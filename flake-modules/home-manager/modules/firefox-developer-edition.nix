{ config, lib, pkgs, specialArgs, ... }:
  let
    inherit (specialArgs) isGui;
    inherit (pkgs.stdenv) isLinux;
  in lib.mkIf (isGui && isLinux) {
    repository.symlink.xdg.dataFile = {
      "applications/my-firefox.desktop".source = "firefox-developer-edition/my-firefox.desktop";
    };

    repository.symlink.home.file.".local/bin/my-firefox".source = "firefox-developer-edition/my-firefox";
  }