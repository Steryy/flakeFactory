{ config, lib, ... }:
let
  domain =
    lib.concatStringsSep "." [ "forgejo" (lib.head config.networking.domains) ];
in {

  networking.exposedServices.forgejo = {
    port = config.services.forgejo.settings.server.HTTP_PORT;
  };

  clan.postgresql.users.forgejo = { };
  clan.postgresql.databases.forgejo.create.options = {
    TEMPLATE = "template0";
    LC_COLLATE = "C";
    LC_CTYPE = "C";
    ENCODING = "UTF8";
    OWNER = "forgejo";
  };

  clan.postgresql.databases.forgejo.restore.stopOnRestore = [ "forgejo" ];
  clan.core.state.forgejo.folders = [ config.services.forgejo.stateDir ];
  services.forgejo = {
    database = {
      type = "postgres";
      user = "forgejo";
    };

    enable = true;
    settings = { server = { DOMAIN = domain; }; };
    secrets = { };
  };
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${domain}" = {
        forceSSL = true;
        # enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${
              builtins.toString
              config.services.forgejo.settings.server.HTTP_PORT
            }";
          proxyWebsockets = true;
        };
      };
    };
  };
}
