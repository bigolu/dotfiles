{
  inputs,
  self,
  ...
}: {
  perSystem = {
    lib,
    system,
    pkgs,
    ...
  }: let
    inherit (lib.attrsets) optionalAttrs;
    supportedSystems = with inputs.flake-utils.lib.system; [x86_64-linux x86_64-darwin];
    isSupportedSystem = builtins.elem system supportedSystems;
    makeShell = import ./make-shell;

    portableHomeOutputs = let
      shellBootstrap = makeShell {
        isGui = false;
        inherit pkgs self;
      };
      makeEmptyPackage = packageName: pkgs.runCommand packageName {} ''mkdir -p $out/bin'';
      shellMinimalName = "shell-minimal";
      shellMinimalBootstrap = makeShell {
        name = shellMinimalName;
        isGui = false;
        inherit pkgs self;
        modules = [
          {
            xdg = {
              dataFile = {
                "nvim/site/parser" = lib.mkForce {
                  source = makeEmptyPackage "parsers";
                };
              };
              configFile = {
                # Since I'm removing zoxide I have to remove the generation of its config or else
                # I'll get an error.
                "fish/conf.d/zoxide.fish" = lib.mkForce {
                  text = "";
                };
              };
            };
          }
        ];
        overlays = [
          (_final: _prev: {
            moreutils = makeEmptyPackage "moreutils";
            ast-grep = makeEmptyPackage "ast-grep";
            myPython = makeEmptyPackage "myPython";
            timg = makeEmptyPackage "timg";
            ripgrep-all = makeEmptyPackage "ripgrep-all";
            lesspipe = makeEmptyPackage "lesspipe";
            wordnet = makeEmptyPackage "wordnet";

            # I don't want to override fzf in the full shell because that would cause ripgrep-all to rebuild
            fzf = let
              fzfNoPerl = pkgs.fzf.override {
                perl = makeEmptyPackage "perl";
              };
            in
              pkgs.buildEnv {
                name = "fzf-without-shell-config";
                paths = [fzfNoPerl];
                pathsToLink = ["/bin" "/share/man"];
              };
            # remove zoxide too since it depends on fzf and takes a while to build
            zoxide = makeEmptyPackage "zoxide";
          })
        ];
      };
      terminalBootstrapScriptName = "terminal";
      terminalBootstrap = let
        GUIShellBootstrap = makeShell {
          isGui = true;
          inherit pkgs self;
        };
      in
        pkgs.writeScriptBin
        terminalBootstrapScriptName
        ''
          #!${pkgs.bash}/bin/bash

          set -o errexit
          set -o nounset
          set -o pipefail

          exec ${GUIShellBootstrap}/bin/shell -c 'exec wezterm --config "font_locator=[[ConfigDirsOnly]]" --config "font_dirs={[[${pkgs.myFonts}]]}" --config "default_prog={[[$SHELL]]}" --config "set_environment_variables={SHELL=[[$SHELL]]}"'
        '';
    in {
      apps = {
        shell = {
          type = "app";
          program = "${shellBootstrap}/bin/shell";
        };
        shellMinimal = {
          type = "app";
          program = "${shellMinimalBootstrap}/bin/${shellMinimalName}";
        };
        terminal = {
          type = "app";
          program = "${terminalBootstrap}/bin/${terminalBootstrapScriptName}";
        };
      };

      packages = {
        shell = shellBootstrap;
        shellMinimal = shellMinimalBootstrap;
        terminal = terminalBootstrap;
      };
    };
  in
    optionalAttrs isSupportedSystem portableHomeOutputs;
}
