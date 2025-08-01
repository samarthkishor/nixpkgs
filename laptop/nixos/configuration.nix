# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
  nixos-hardware = builtins.fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
in
{
  imports =
    [
      (import "${nixos-hardware}/framework/13-inch/11th-gen-intel")
      (import "${home-manager}/nixos")
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/New_York";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    services.xserver = {
      enable = true;

      xkb.layout = "us";
      xkb.variant = "colemak";
      xkb.options = "caps:escape";
    };

    services.displayManager.sddm.enable = true;
    services.displayManager.defaultSession = "plasma"; # use Wayland instead of X11
    services.desktopManager.plasma6.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    # Enable firmware update manager
    services.fwupd.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Keyboard customization: use some macOS shortcuts
    # from https://github.com/canadaduane/meta-mac/blob/main/keyd/default.conf
    services.keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = [ "*" ];
          settings = {
            main = {
              # Create new "cmd" button
              leftalt = "layer(meta_mac)";
              # Swap meta/alt
              leftmeta = "leftalt";
            };
            "meta_mac:C" = {
              shift = "layer(meta_mac_shift)";
              left = "home";
              right = "end";
            };
            "meta_mac_shift:C-S" = {
              left = "S-home";
              right = "S-end";
            };
          };
        };
      };
    };
    # Optional, but makes sure that when you type the make palm rejection work with keyd
    # https://github.com/rvaiya/keyd/issues/723
    environment.etc."libinput/local-overrides.quirks".text = ''
      [Serial Keyboards]
      MatchUdevType=keyboard
      MatchName=keyd virtual keyboard
      AttrKeyboardIntegration=internal
    '';

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.samarth = {
      isNormalUser = true;
      description = "Samarth Kishor";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        firefox
      ];
    };

    # Home Manager config
    home-manager.users.samarth = { pkgs, ... }: {
      home.packages = with pkgs; [
        atool
        direnv
        emacs-pgtk
        gh # Github CLI
        git
        gnumake
        ispell
        ripgrep
      ];

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

      home.stateVersion = "23.11"; # Don't change
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      neovim
    ];

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-serif
      fira-code
      nerd-fonts.symbols-only
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      # services.openssh.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "23.11"; # Did you read the comment?

}
