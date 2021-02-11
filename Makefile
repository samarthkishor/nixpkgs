.PHONY: darwin nixos switch

darwin:
	darwin-rebuild switch -I darwin-config=${HOME}/.config/nixpkgs/darwin/configuration.nix

nixos:
	NIX_PATH=${NIX_PATH}:nixos-config=${HOME}/.config/nixpkgs/nixos/configuration.nix sudo nixos-rebuild switch -I nixos-config=${HOME}/.config/nixpkgs/nixos/configuration.nix

switch:
	nix-shell --run "home-manager switch"
