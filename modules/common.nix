## This file contains the settings that are shared between Darwin and Linux systems

{ inputs, config, lib, pkgs, ... }:

let
  defaultUser = "samarth";
  homePrefix = if pkgs.stdenv.isDarwin then "/Users" else "/home";
  userShell = "zsh";
in {
  users.users = {
    "${defaultUser}" = {
      description = "Samarth Kishor";
      home = "${homePrefix}/${defaultUser}";
      shell = pkgs.${userShell};
    };
  };

  nix = {
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      ${lib.optionalString (config.nix.package == pkgs.nixFlakes)
      "experimental-features = nix-command flakes"}
    '';
    trustedUsers = [ "${defaultUser}" "root" "@admin" "@wheel" ];
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    buildCores = 8;
    maxJobs = 8;
    readOnlyStore = true;

    binaryCaches = [ "https://cache.nixos.org" ];
    binaryCachePublicKeys =
      [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  };

  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [ jetbrains-mono iosevka ];
  };
}
