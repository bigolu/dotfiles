{ self, ... }:
  {
    imports = [
      ./plugins
      ./xdg.nix
      ./pinned-versions.nix
      ./missing-packages.nix
      ./meta-packages.nix
    ];

    flake =
      let
        makeMetaOverlay = overlays: final: prev:
          let
            callOverlay = overlay: overlay final prev;
            overlayResults = builtins.map callOverlay overlays;
            mergedOverlayResults = self.lib.recursiveMerge overlayResults;
          in
            mergedOverlayResults;

        metaOverlay = makeMetaOverlay [
          self.overlays.plugins
          self.overlays.xdg
          self.overlays.pinnedVersions
          self.overlays.missingPackages
          self.overlays.metaPackages
        ];
      in
        {
          lib.overlay = { inherit makeMetaOverlay; };
          overlays.default = metaOverlay;
        };
  }