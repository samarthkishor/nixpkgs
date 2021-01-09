{ config, pkgs, ... }:
let theme = builtins.readFile ./Solarized_Light.conf;
in {
  programs.kitty = {
    enable = true;
    font = {
      package = pkgs.jetbrains-mono;
      name = "JetBrains Mono";
    };
    settings = {
      allow_remote_control = "yes";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      font_size = 14;
      strip_trailing_spaces = "smart";
      enable_audio_bell = "no";
      term = "xterm-256color";
      macos_titlebar_color = "background";
      macos_option_as_alt = "yes";
      scrollback_lines = 10000;
    };
    extraConfig = ''
      ${theme}
    '';
  };
}
