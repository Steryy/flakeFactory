{
  _class = "clan.service";
  manifest.name = "@local/lldap";
  imports = [
    ./server
    ./server/lldap.nix
    ./client.nix
  ];
  roles.client = {};
}
