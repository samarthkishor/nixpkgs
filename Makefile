.PHONY: darwin switch

darwin:
	darwin-rebuild switch -I darwin-config=${HOME}/.config/nixpkgs/darwin/configuration.nix

switch:
	nix-shell --run "home-manager switch"
