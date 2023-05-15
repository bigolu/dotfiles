# This output lets me run my shell environment, both programs and their config files, completely from the nix store.
# Useful for headless servers or containers.
{ inputs, self, ... }:
  {
    perSystem = {lib, system, pkgs, ...}:
      let
        inherit (lib.attrsets) optionalAttrs;
        shellOutput =
          let
            hostName = "no-host";
            homeManagerOutput = self.lib.makeFlakeOutput system {
              inherit hostName;
              modules = with self.lib.modules; [
                profile.system-administration
                # I want a self contained executable so I can't have symlinks that point outside the Nix store.
                {config.repository.symlink.makeCopiesInstead = true;}
              ];
              isGui = false;
            };
            inherit (homeManagerOutput.legacyPackages.homeConfigurations.${hostName}) activationPackage;
            # I don't want the programs that this script depends on to be in the $PATH since they are not
            # necessarily part of my Home Manager configuration so I'll set them to variables instead.
            coreutilsBinaryPath = "${pkgs.coreutils}/bin";
            mktemp = "${coreutilsBinaryPath}/mktemp";
            copy = "${coreutilsBinaryPath}/cp";
            chmod = "${coreutilsBinaryPath}/chmod";
            basename = "${coreutilsBinaryPath}/basename";
            which = "${pkgs.which}/bin/which";
            foreignEnvFunctionPath = "${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d";
            fish = "${pkgs.fish}/bin/fish";
            shellBootstrapScriptName = "shell";
            shellBootstrapScript = import ./shell-bootstrap-script.nix
              {
                inherit
                  activationPackage
                  mktemp
                  copy
                  chmod
                  fish
                  coreutilsBinaryPath
                  basename
                  which
                  foreignEnvFunctionPath
                  ;
              };
            shellBootstrap = pkgs.writeScriptBin shellBootstrapScriptName shellBootstrapScript;
          in
            {
              apps.default = {
                type = "app";
                program = "${shellBootstrap}/bin/${shellBootstrapScriptName}";
              };
              packages.shell = shellBootstrap;
            };
        supportedSystems = with inputs.flake-utils.lib.system; [ x86_64-linux x86_64-darwin ];
        isSupportedSystem = builtins.elem system supportedSystems;
      in
        optionalAttrs isSupportedSystem shellOutput;
  }
