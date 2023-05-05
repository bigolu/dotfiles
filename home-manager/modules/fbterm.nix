{ config, lib, pkgs, specialArgs, ... }:
  let
    inherit (pkgs.stdenv) isLinux;
    inherit (specialArgs) isGui;
  in lib.mkIf (isLinux && isGui) {
    home.packages = with pkgs; [
      fbterm
    ];

    repository.symlink.home.file = {
      ".fbtermrc".source = "fbterm/fbtermrc";
    };
  }
