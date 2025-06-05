{ config,  lib, ... }:
let userNames = lib.attrNames config.clan.postgresql.users;
in {

  services.postgresql = {
    enable = true;
    ensureUsers = map (name: {
      inherit name;
      ensureDBOwnership = true;
    }) userNames;
    ensureDatabases = userNames;
    identMap = lib.concatStringsSep "\n"
      (map (x: " superuser_map      root      ${x}") userNames);

  };
}
