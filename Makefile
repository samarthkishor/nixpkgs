.PHONY: laptop home

laptop: $(wildcard laptop/*)
	NIX_PATH=${NIX_PATH}:nixos-config=${HOME}/.config/nixpkgs/laptop/nixos/configuration.nix sudo nixos-rebuild switch -I nixos-config=${HOME}/.config/nixpkgs/laptop/nixos/configuration.nix

home:
	nix-shell --run "home-manager switch"
