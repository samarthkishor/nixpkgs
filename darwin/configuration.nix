{ config, lib, pkgs, ... }:

let
  homeDir = builtins.getEnv ("HOME");
  user_name = "samarth";
  user_full_name = "Samarth Kishor";
  user_description = "Samarth Kishor";

in with pkgs.stdenv;
with lib; {

  #######################
  # Modules and Imports #
  #######################

  imports = [
    # Personal modules
    ./modules/homebrew-bundle.nix

    # import home-manager from niv
    "${(import <home-manager> { }).path}/nix-darwin"

    # Other nix-darwin configurations
    # ./brew.nix  # TODO fix HomeBrew config
    ./defaults.nix
  ]; # ++ lib.filter lib.pathExists [ ./private.nix ];

  #####################
  # Nix configuration #
  #####################

  nixpkgs.config = import ../config.nix;

  # TODO overlays to root
  # nixpkgs.overlays = [ (import ./emacs-darwin.nix) ];

  # nixpkgs.overlays = [ (import ../overlays) ];
  # nixpkgs.config.packageOverrides = pkgs: {
  #   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #     inherit pkgs;
  #   };
  # };

  # nixpkgs.overlays = [ emacs-overlay ];

  nix.package = pkgs.nix;
  nix.trustedUsers = [ "root" "samarth" "@admin" ];

  # TODO
  # nix.nixPath = [
  #   "darwin-config=$HOME/src/nix/config/darwin.nix"
  #   "home-manager=$HOME/src/nix/home-manager"
  #   "darwin=$HOME/src/nix/darwin"
  #   "nixpkgs=$HOME/src/nix/nixpkgs"
  #   "ssh-config-file=$HOME/.ssh/config"
  #   "ssh-auth-sock=${xdg_configHome}/gnupg/S.gpg-agent.ssh"
  # ];

  # environment.shells = [ pkgs.zsh ];
  environment.darwinConfig =
    "${homeDir}/.config/nixpkgs/darwin/configuration.nix";

  # TODO maybe after having extracted it? What are the benefits?
  # environment.systemPackages = import ./packages.nix { inherit pkgs; }

  environment.systemPath = [
    "$HOME/.poetry/bin"
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin:$PATH"
    "/usr/local/bin"
    "$HOME/.npm-packages/bin"
    "$HOME/.cargo/bin"
  ];

  environment.variables = {
    EDITOR = "nvim";
    EMACS = "/Applications/Emacs.app/Contents/MacOS/Emacs";
    BROWSER = "firefox";
  };

  programs.nix-index.enable = true;

  ################
  # home-manager #
  ################

  home-manager.users.samarth = import ../home-manager/configuration.nix;

  ########################
  # System configuration #
  ########################

  # Fonts
  # fonts.enableFontDir = true;
  # fonts.fonts = with pkgs; [
  #   recursive
  #   jetbrains-mono
  #   (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  # ];

  networking = {
    knownNetworkServices = [ "Wi-Fi" "Bluetooth PAN" "Thunderbolt Bridge" ];
    hostName = "Samarths-MBP";
    computerName = "Samarths-MBP";
    localHostName = "Samarths-MBP";
    # dns = [
    #   "1.1.1.1"
    #   "8.8.8.8"
    # ];
  };

  system.stateVersion = 4;

  services.nix-daemon.enable = true;
  # services.activate-system.enable = true;
  # services.gpg-agent.enable = true;
  # services.keybase.enable = true;
  services.lorri.enable = true;

  users.users.${user_name} = {
    description = "${user_description}";
    home = "${homeDir}";
    shell = pkgs.zsh;
  };

}
