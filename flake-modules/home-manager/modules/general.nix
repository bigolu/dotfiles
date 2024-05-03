{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  inherit (lib.attrsets) optionalAttrs;
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (specialArgs) repositoryDirectory flakeInputs;
in {
  # I'm not symlinking the whole directory because EmmyLua is going to generate
  # lua-language-server annotations in there.
  home.file = optionalAttrs isDarwin {
    ".hammerspoon/Spoons/EmmyLua.spoon" = {
      source = "${specialArgs.flakeInputs.spoons}/Source/EmmyLua.spoon";
      recursive = true;
    };
  };

  programs.fish.interactiveShellInit = ''
    fish_add_path --global --prepend \
    ${
      lib.escapeShellArgs ([
          (config.lib.file.mkOutOfStoreSymlink "${specialArgs.repositoryDirectory}/dotfiles/general/bin")
        ]
        ++ lib.lists.optionals isDarwin [
          (config.lib.file.mkOutOfStoreSymlink "${specialArgs.repositoryDirectory}/dotfiles/general/bin-macos")
        ])
    }
  '';

  # When switching generations, stop obsolete services and start ones that are wanted by active units.
  systemd = optionalAttrs isLinux {
    user.startServices = "sd-switch";
  };

  repository = {
    directory = repositoryDirectory;
    directoryPath = flakeInputs.self.outPath;

    symlink = {
      baseDirectory = "${repositoryDirectory}/dotfiles";
    };

    git.onChange = [
      {
        # This should be the first check since other checks might depend on new files
        # being linked, or removed files being unlinked, in order to work. For example, if a new
        # bat theme is added, the theme needs to be linked before we can rebuild the bat cache.
        priority = 100;
        patterns = {
          added = [".*"];
          deleted = [".*"];
          modified = [''^flake-modules/'' ''^flake\.nix$'' ''^flake\.lock$''];
        };
        action = ''
          just switch
        '';
      }
      {
        patterns = {
          modified = [''^\.lefthook.yml$''];
        };
        action = ''
          just install-git-hooks
        '';
      }
    ];
  };
}
