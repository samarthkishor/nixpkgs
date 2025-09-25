{ config, pkgs, lib, ... }:

{
  users.users.samarth.packages = with pkgs; [
    atool
    (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {}) # nix secrets manager
    direnv
    fd # faster find
    firefox
    gh # Github CLI
    git
    gnumake
    ispell
    jq
    nixfmt-rfc-style
    ripgrep
    shellcheck
  ];
}
