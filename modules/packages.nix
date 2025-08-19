{ config, pkgs, lib, ... }:

{
  users.users.samarth.packages = with pkgs; [
    atool
    direnv
    fd # faster find
    firefox
    gh # Github CLI
    git
    gnumake
    ispell
    nixfmt-rfc-style
    ripgrep
    shellcheck
  ];
}
