{ config, pkgs, ... }:

let
  sources = import ../nix/sources.nix;
  homeDir = builtins.getEnv ("HOME");

  # Handly shell command to view the dependency tree of Nix packages
  depends = pkgs.writeScriptBin "depends" ''
    dep=$1
    nix-store --query --requisites $(which $dep)
  '';

  run = pkgs.writeScriptBin "run" ''
    nix-shell --pure --run "$@"
  '';

  # Collect garbage, optimize store, repair paths
  nix-cleanup-store = pkgs.writeShellScriptBin "nix-cleanup-store" ''
    nix-collect-garbage -d
    nix optimise-store 2>&1 | sed -E 's/.*'\'''(\/nix\/store\/[^\/]*).*'\'''/\1/g' | uniq | sudo -E ${pkgs.parallel}/bin/parallel 'nix-store --repair-path {}'
  '';

  # Symlink macOS apps installed via Nix into ~/Applications
  nix-symlink-apps-macos = pkgs.writeShellScriptBin "nix-symlink-apps-macos" ''
    for app in $(find ~/Applications -name '*.app')
    do
      if test -L $app && [[ $(greadlink -f $app) == /nix/store/* ]]; then
        rm $app
      fi
    done
    for app in $(find ~/.nix-profile/Applications/ -name '*.app' -exec greadlink -f '{}' \;)
    do
      echo "symlinking $(basename $app) into ~/Applications"
      ln -s $app ~/Applications/$(basename $app)
    done
  '';

  # Update Homebrew pagkages/apps
  brew-bundle-update = pkgs.writeShellScriptBin "brew-bundle-update" ''
    brew update
    brew bundle --file=~/.config/nixpkgs/Brewfile
  '';

  # Remove Homebrew pakages/apps not in Brewfile
  brew-bundle-cleanup = pkgs.writeShellScriptBin "brew-bundle-cleanup" ''
    brew bundle cleanup --zap --force --file=~/.config/nixpkgs/Brewfile
  '';

  scripts = [
    depends
    run
    nix-cleanup-store
    nix-symlink-apps-macos
    brew-bundle-update
    brew-bundle-cleanup
  ];

  # customPython = pkgs.python39.buildEnv.override {
  #   extraLibs = with pkgs.python39Packages; [ ipython pip ];
  # };

in {
  imports = [ ./shells.nix ./emacs.nix ];

  home = {
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
    stateVersion = "20.09";

    sessionPath = [
      "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin:$PATH"
      "/usr/local/bin:$PATH"
      "/usr/local/sbin:$PATH"
      # "$HOME/.npm-packages/bin"
    ];

    sessionVariables = {
      EDITOR = "nvim";
      LIBRARY_PATH = "/usr/bin/gcc";
      BROWSER = "firefox";
    };

    ################
    ### DOTFILES ###
    ################
    file.".config/mpv/mpv.conf".source = ../dotfiles/mpv.conf;
    # Email
    file.".mbsyncrc".source = ../dotfiles/mbsyncrc;
    file.".msmtprc".source = ../dotfiles/msmtprc;
  };

  fonts.fontconfig.enable = true;

  news.display = "silent";

  programs.home-manager.enable = true;

  programs.htop = {
    enable = true;
    showProgramPath = true;
  };

  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };

  programs.fzf.enable = true;

  programs.git = {
    # package = pkgs.gitAndTools.gitFull;
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
        # pager = "delta --dark";
        whitespace = "trailing-space,space-before-tab";
        # fileMode = false;
      };

      # commit.gpgsign = "true";
      # gpg.program = "gpg2";

      ui.color = "always";
      github.user = "samarthkishor";

      protocol.keybase.allow = "always";
      credential.helper = "osxkeychain";
      pull.rebase = "false";
    };
  };

  programs.ssh = {
    enable = false;
    # hashKnownHosts = true;
    # userKnownHostsFile = "${xdg.configHome}/ssh/known_hosts";
  };

  # programs.xdg = {
  #   enable = true;

  #   configHome = "${home_directory}/.config";
  #   dataHome   = "${home_directory}/.local/share";
  #   cacheHome  = "${home_directory}/.cache";

  #   configFile."gnupg/gpg-agent.conf".text = ''
  #     enable-ssh-support
  #     default-cache-ttl 86400
  #     max-cache-ttl 86400
  #     pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  #   '';
  # };

  programs.starship.enable = true;

  programs.vim.enable = true;

  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {
      inherit (tpkgs)
        capt-of catchfile dvipng framed fvextra minted upquote wrapfig
        scheme-medium latexmk;
    };
  };

  home.packages = with pkgs;
    [
      ## Utilities
      bash # /bin/bash
      bat # cat replacement written in Rust
      cachix # Nix binary cache
      cmake
      coreutils # GNU CLI programs
      curl
      gitAndTools.delta # Fancy diffs
      direnv # Per-directory environment variables
      exa # ls replacement written in Rust
      fd # find replacement written in Rust
      fzf # Fuzzy finder
      git-lfs
      gitAndTools.gh
      gitAndTools.git-crypt
      graphviz # dot
      gnupg # gpg
      httpie # Like curl but more user friendly
      jq # JSON parsing for the CLI
      lorri # Easy Nix shell
      libtool
      less
      niv # Nix dependency management
      nixpkgs-fmt
      nodePackages.prettier
      pinentry_mac # Necessary for GPG
      procs
      protobuf # Protocol Buffers
      ripgrep # grep replacement written in Rust
      rsync
      starship # ZSH prompt
      thefuck
      tree # Visualize directory structure
      tmux
      watch
      wget
      xsv # CSV file parsing utility
      yarn # Node.js package manager
      youtube-dl # Download videos

      ## Programming Languages and related tools
      adoptopenjdk-bin # Java
      clang # C/C++
      # gcc # C/C++
      nixfmt
      nodejs # node and npm
      # customPython # Python3
    ] ++ scripts;
}
