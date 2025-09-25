{ config, lib, pkgs, ... }:

let
  agenix = builtins.fetchTarball https://github.com/ryantm/agenix/archive/main.tar.gz;
in
{
  imports = [
    (import "${agenix}/modules/age.nix")
  ];

  # Secrets management
  age = {
    identityPaths = [ "/home/samarth/.ssh/id_ed25519" ]; # TODO don't hardcode user
    secrets = {
      tailscale-key = {
        file = ../secrets/tailscale-key.age;
      };
    };
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale-key.path;
  };

  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up --auth-key file:${config.age.secrets.tailscale-key.path}
    '';
  };

  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # let you SSH in over the public internet
    allowedTCPPorts = [ 22 ];
  };
}
