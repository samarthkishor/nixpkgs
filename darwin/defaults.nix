{ ... }:

let homeDir = builtins.getEnv ("HOME");

in {

  system.activationScripts.postActivation.text = ''
    # Enable HiDPI display modes (requires restart)
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

    # Stop iTunes from responding to the keyboard media keys
    launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2>/dev/null

    # Use column view in all Finder windows by default
    # Four-letter codes for the other view modes: `icnv`, `Nslw`, `Flwv`
    defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

    # Show the ~/Library folder
    chflags nohidden ~/Library
  '';

  system.defaults = {
    dock = {
      autohide = true;
      # autohide-time-modifier = 0.5;  # TODO figure out why the type is wrong
      mru-spaces = false;
      expose-group-by-app = true;
      tilesize = 36;
      orientation = "bottom";
    };

    loginwindow = {
      GuestEnabled = false;
      DisableConsoleAccess = true;
    };

    screencapture.location = "${homeDir}/Desktop";

    finder = {
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      FXEnableExtensionChangeWarning = false;
    };

    LaunchServices.LSQuarantine = false;

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      TrackpadRightClick = true;
    };

    NSGlobalDomain = {
      # "com.apple.trackpad.scaling"         = "3.0";
      AppleFontSmoothing = 1;
      ApplePressAndHoldEnabled = true;
      AppleKeyboardUIMode = 3;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleShowScrollBars = "Automatic";
      AppleShowAllExtensions = true;
      AppleTemperatureUnit = "Fahrenheit";
      # InitialKeyRepeat                     = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      _HIHideMenuBar = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      # Enable full keyboard access for all controls
      # (e.g. enable Tab in modal dialogs)
    };

    alf = {
      globalstate = 1;
      allowsignedenabled = 1;
      allowdownloadsignedenabled = 1;
      stealthenabled = 1;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

}
