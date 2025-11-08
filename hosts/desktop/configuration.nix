{
  config,
  pkgs,
  lib,
  ...
}:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
    ../../modules/common.nix
    ../../modules/packages.nix
    ../../modules/tailscale.nix
    # Include the results of the hardware scan
    ./hardware-configuration.nix
  ];

  nixpkgs.overlays = [
    (import (
      builtins.fetchTarball {
        url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
      }
    ))
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

  # Configure keyboard
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        extraConfig = ''
          # Mac-Like Configuration Example
          # Based off https://github.com/rvaiya/keyd/blob/master/examples/macos.conf
          #
          # Uses "Alt" button to the left of spacebar as "Cmd" key
          #
          [ids]
          *

          [main]
          # Create a new "Cmd" button, with various Mac OS-like features below
          leftmeta = layer(meta_mac)

          # Swap ctrl/meta
          leftcontrol = leftmeta

          # meta_mac modifier layer; inherits from 'Ctrl' modifier layer
          #
          # The main part! Using this layer, we can remap our new "Cmd" key to
          # do almost everything our muscle memory might need...
          [meta_mac:C]
          shift = layer(meta_mac_shift)
          # Move cursor to beginning of line
          left = home
          # Move cursor to end of Line
          right = end
          # Switch to next application
          tab = A-tab

          [meta_mac_shift:C-S]
          # Highlight to beginning of line
          left = S-home
          # Highlight to end of Line
          right = S-end
          # Cmd-Shift-Tab switches to the previous application
          tab = A-S-tab
        '';
      };
    };
  };

  # Configure host-only packages
  users.users.samarth.packages = with pkgs; [
    # Since this is XFCE, we need the regular gtk version of emacs
    (emacs.pkgs.withPackages (epkgs: with epkgs; [
        use-package
        dired-subtree
	trashed
	which-key
	doom-modeline
	magit
	tempel
	apheleia
	nix-mode
	markdown-mode
	yaml-mode
	json-mode
	avy
	consult
	embark-consult
	embark
	vertico
	# vertico-directory
	marginalia
	corfu
	# corfu-popupinfo
	corfu-terminal
	cape
	kind-icon
	eat
	orderless
	nerd-icons
	nerd-icons-completion
	nerd-icons-corfu
	nerd-icons-dired
	wgrep
	evil
	jinx
	olivetti
        tree-sitter-langs
        (treesit-grammars.with-grammars (grammars: [
          grammars.tree-sitter-bash
          grammars.tree-sitter-c
          grammars.tree-sitter-go
          grammars.tree-sitter-gomod
          grammars.tree-sitter-java
          grammars.tree-sitter-javascript
          grammars.tree-sitter-json
          grammars.tree-sitter-latex
          grammars.tree-sitter-markdown
          grammars.tree-sitter-markdown-inline
          grammars.tree-sitter-nix
          grammars.tree-sitter-ocaml
          grammars.tree-sitter-ocaml-interface
          grammars.tree-sitter-python
        ]))
      ]
    ))
    # XFCE plugins
    xfce.xfce4-xkb-plugin
    xfce.xfce4-whiskermenu-plugin
    xfce.thunar-archive-plugin
  ];

  # Configure home-manager
  home-manager.users.samarth = import ../../modules/home-manager.nix;
  home-manager.backupFileExtension = "backup";

  # Configure Steam
  programs.java.enable = true;
  programs.steam = {
    enable = true;
  };

  # Server stuff
  services.immich = {
    enable = true;
    port = 2283;
    host = "0.0.0.0";
    openFirewall = true;
  };

  system.stateVersion = "25.05"; # DO NOT DELETE!
}
