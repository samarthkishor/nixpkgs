{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{
  imports = [
    (import "${home-manager}/nixos")
    ../../modules/common.nix
    ../../modules/packages.nix
    # Include the results of the hardware scan
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixbox";
  
  # Configure XFCE
  services.xserver.enable = true;
  services.xserver = {
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
 
    # NOTE xkb options are in common.nix
  };

  # Configure host-only packages
  users.users.samarth.packages = with pkgs; [
    # Since this is XFCE, we need the regular gtk version of emacs
    emacs-gtk
    # XFCE plugins
    xfce.xfce4-xkb-plugin
    xfce.xfce4-whiskermenu-plugin
  ];

  # Configure home-manager
  home-manager.users.samarth = import ../../modules/home-manager.nix;
  home-manager.backupFileExtension = "backup";

  system.stateVersion = "25.05"; # DO NOT DELETE!
}
