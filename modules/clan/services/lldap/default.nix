{
  _class = "clan.service";
  manifest.name = "@local/lldap";
  imports = [
    ./server
    ./server/lldap.nix
    ./client.nix
  ];
  roles.client = {
    description = "Client for lldap server. It also allows for creating shared credentials with server.";
  };
}
