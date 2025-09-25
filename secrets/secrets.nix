let
  samarth-nixbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIsf28t7TL9C7DEfv8qO/mff1p3GRAk2+qUy36HQhOkT samarthkishor1@gmail.com";
  users = [ samarth-nixbox ];
in
{
  "samarth-nixbox-secret.age" = {
    publicKeys = [ samarth-nixbox ];
    armor = true;
  };

  "tailscale-key.age" = {
    publicKeys = [ samarth-nixbox ];
    armor = true;
  };
}
