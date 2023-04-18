{ config, lib, pkgs, ... }:
  let
    inherit (import ../util.nix {inherit config lib;})
      makeSymlinkToRepo
      ;
    inherit (lib.lists) optionals;
    inherit (pkgs.stdenv) isLinux;
    inherit (lib.attrsets) optionalAttrs;
  in
    {
      imports = [
        ../unit/bat.nix
        ../unit/git.nix
        ../unit/tmux.nix
        ../unit/wezterm.nix
        ../unit/fbterm.nix
      ];

      home.packages = with pkgs; [
        pipr
        timg
        autossh
        doggo
        duf
        fd
        fzf
        gping
        jq
        lsd
        moreutils
        ncdu
        ripgrep
        tealdeer
        tree
        viddy
        watchman
        zoxide
        file
      ] ++ optionals isLinux [
        trash-cli
      ];

      home.file = {
        # less
        ".lesskey".source = makeSymlinkToRepo "less/lesskey";

        # ripgrep
        ".ripgreprc".source = makeSymlinkToRepo "ripgrep/ripgreprc";

        # for any searchers e.g. ripgrep
        ".ignore".source = makeSymlinkToRepo "search/ignore";
      } // optionalAttrs isLinux {
        ".local/bin/pbcopy".source = makeSymlinkToRepo "general/executables/osc-copy";
        ".local/bin/pbpaste" = {
          text = ''
            #!${pkgs.fish}/bin/fish

            if type --query wl-paste
              wl-paste
            else if type --query xclip
              xclip -selection clipboard -out
            else
              echo "Error: Can't find a program to pasting clipboard contents" 1>/dev/stderr
            end
          '';
          executable = true;
        };
      };

      xdg.configFile = {
        # lsd
        "lsd".source = makeSymlinkToRepo "lsd";

        # pipr
        "pipr/pipr.toml".source = makeSymlinkToRepo "pipr/pipr.toml";

        # viddy
        "viddy.toml".source = makeSymlinkToRepo "viddy/viddy.toml";

        # watchman
        "watchman/watchman.json".source = makeSymlinkToRepo "watchman/watchman.json";
      };
    }
