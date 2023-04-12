{ config, lib, pkgs, ... }:
  let
    inherit (import ../util.nix {inherit config lib;})
      makeOutOfStoreSymlink
      runAfterLinkGeneration
      ;
  in
    {
      xdg.configFile = {
        "bat/config".source = makeOutOfStoreSymlink "bat/config";
        "bat/themes/base16-brighter.tmTheme".source = makeOutOfStoreSymlink "bat/base16-brighter.tmTheme";
      };

      home.packages = with pkgs; [
        bat
      ];

      home.activation.batSetup = runAfterLinkGeneration ''
        export PATH="${pkgs.bat}/bin:${pkgs.moreutils}/bin:$PATH"
        chronic bat cache --build
      '';
    }