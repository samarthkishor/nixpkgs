.PHONY: laptop desktop

laptop: $(wildcard laptop/*)
	NIX_PATH=${NIX_PATH}:nixos-config=${HOME}/.config/nixpkgs/hosts/laptop/configuration.nix sudo nixos-rebuild switch -I nixos-config=${HOME}/.config/nixpkgs/hosts/laptop/configuration.nix

desktop: $(wildcard desktop/*)
	NIX_PATH=${NIX_PATH}:nixos-config=${HOME}/.config/nixpkgs/hosts/desktop/configuration.nix sudo nixos-rebuild switch -I nixos-config=${HOME}/.config/nixpkgs/hosts/desktop/configuration.nix
