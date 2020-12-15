{ ... }:

let user_name = "samarth";
in {
  homebrew = {
    enable = true;
    formulae = [
      "borkdude/brew/babashka" # Clojure interpreter for scripts
    ];
    cask_args.appdir = "/Users/${user_name}/Applications";
    casks = [
      # Quick Look plugins
      "qlcolorcode"
      "qlimagesize"
      "qlmarkdown"
      "qlstephen"
      "qlvideo"
    ];
    taps = [ "borkdude/brew" ];
  };
}
