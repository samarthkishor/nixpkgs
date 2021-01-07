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
    ./darwin/modules/homebrew-bundle.nix

    # import home-manager from niv
    "${(import <home-manager> { }).path}/nix-darwin"

    ./darwin/defaults.nix
  ];

  #####################
  # Nix configuration #
  #####################

  nixpkgs.config = import ./config.nix;

  nix.package = pkgs.nix;
  nix.trustedUsers = [ "root" "samarth" "@admin" ];

  environment.darwinConfig =
    "${homeDir}/.config/nixpkgs/darwin-configuration.nix";

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

  home-manager.users.samarth = import ./home.nix;

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
