{
  lib,
  pkgs,
  ...
}: let
  fzfWithoutShellConfig = pkgs.buildEnv {
    name = "fzf-without-shell-config";
    paths = [pkgs.fzf];
    pathsToLink = ["/bin" "/share/man"];
  };
in {
  home.packages = [
    fzfWithoutShellConfig
  ];

  repository.symlink.xdg.executable = {
    "fzf-tmux-zoom".source = "fzf/fzf-tmux-zoom";
    "fzf-help-preview".source = "fzf/fzf-help-preview";
    "fzf".source = "fzf/fzf-wrapper.fish";
  };

  repository.symlink.xdg.configFile = {
    "fish/conf.d/fzf-default-opts.fish".source = "fzf/fzf-default-opts.fish";
  };

  home.activation.fzfSetup =
    lib.hm.dag.entryAfter
    ["writeBoundary"]
    ''
      history_file="''${XDG_DATA_HOME:-''$HOME/.local/share}/fzf/fzf-history.txt"
      mkdir -p "$(dirname "$history_file")"
      touch "$history_file"
    '';
}
