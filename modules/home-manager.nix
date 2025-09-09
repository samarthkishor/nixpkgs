{ config, pkgs, lib, ... }:

{
  # Home Manager config

  gtk = {
    enable = true;
    theme = {
      name = "Fluent";
      package = pkgs.fluent-gtk-theme;
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Samarth Kishor";
    userEmail = "samarthkishor1@gmail.com";

    # Replaces ~/.gitignore
    ignores = [
      ".cache/"
      ".DS_Store"
      ".idea/"
      "*.swp"
      "built-in-stubs.jar"
      "dumb.rdb"
      ".elixir_ls/"
      ".vscode/"
      "node_modules/"
      "npm-debug.log"
      ".bbl"
      ".blg"
    ];

    # Global Git config
    extraConfig = {
      core = {
        editor = "nvim";
        whitespace = "trailing-space,space-before-tab";
      };

      ui.color = "always";
      github.user = "samarthkishor";

      protocol.keybase.allow = "always";
      pull.rebase = "true";
    };
  };

  fonts.fontconfig.enable = true;

  home.stateVersion = "23.11"; # Don't delete
}
