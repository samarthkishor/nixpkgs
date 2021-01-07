{ config, lib, pkgs, ... }:

let
  # Set all shell aliases programatically
  shellAliases = {
    # Aliases for commonly used tools
    grep = "grep --color=auto";
    ll = "ls -lh";
    ls = "exa";

    # Reload zsh
    szsh = "source ~/.zshrc";

    # Reload home manager and zsh
    reload = "cd ~/.config/nixpkgs && ./switch.sh && cd - && source ~/.zshrc";

    # Nix garbage collection
    garbage = "nix-collect-garbage -d && docker image prune --all --force";

    # See which Nix packages are installed
    installed = "nix-env --query --installed";

    # emacs
    emacsclient = "/Applications/Emacs.app/Contents/MacOS/bin/emacsclient";
    em = "emacsclient -n ";
  };
in {
  programs.zsh = {
    inherit shellAliases;
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    history.extended = true;
    envExtra = ''
      export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
      export PYENV_SHELL="zsh"
      # export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
    '';

    # Called whenever zsh is initialized
    initExtra = ''
      eval "$(starship init zsh)"
      eval "$(thefuck --alias)"

      export TERM="xterm-256color"

      # source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

      bindkey -e

      # Nix setup (environment variables, etc.)
      if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
      fi

      # Load environment variables from a file; this approach allows me to not
      # commit secrets like API keys to Git
      # if [ -e ~/.env ]; then
      #   . ~/.env
      # fi

      # Autocomplete for various utilities
      # source <(gh completion --shell zsh)

      # pyenv
      # if [ -n "$(which pyenv)" ]; then
      #   eval "$(pyenv init -)"
      # fi

      # Start up Docker daemon if not running
      # if [ $(docker-machine status default) != "Running" ]; then
      #   docker-machine start default
      # fi

      if [ -f "/Applications/Emacs.app/Contents/MacOS/Emacs" ]; then
        export EMACS="/Applications/Emacs.app/Contents/MacOS/Emacs"
        alias emacs="$EMACS -nw"
      fi

      if [ -f "/Applications/Emacs.app/Contents/MacOS/bin/emacsclient" ]; then
        alias emacsclient="/Applications/Emacs.app/Contents/MacOS/bin/emacsclient"
      fi
    '';
  };
}
