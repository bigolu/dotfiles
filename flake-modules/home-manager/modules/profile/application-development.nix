{pkgs, ...}: {
  imports = [
    ../direnv.nix
    ../firefox-developer-edition.nix
    ../git.nix
    ../wezterm.nix
  ];

  home.packages = with pkgs; [
    cloudflared
  ];

  repository.symlink = {
    home.file = {
      ".yashrc".source = "yash/yashrc";
      ".cloudflared/config.yaml".source = "cloudflared/config.yaml";
      ".markdownlint.jsonc".source = "markdownlint/markdownlint.jsonc";
    };

    xdg.configFile = {
      "pip/pip.conf".source = "python/pip/pip.conf";
      "ipython/profile_default/ipython_config.py".source = "python/ipython/ipython_config.py";
      "ipython/profile_default/startup" = {
        source = "python/ipython/startup";
        recursive = true;
      };
    };
  };
}
