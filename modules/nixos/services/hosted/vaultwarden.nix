{ config, lib, pkgs, ... }:
let
  cfg = {
    port = config.services.vaultwarden.config.ROCKET_PORT;
    domain = "vaultwarden.${lib.head config.networking.domains}";
  };
in {
  clan.core.postgresql.users.vaultwarden = { };
  clan.core.postgresql.databases.vaultwarden.create.options = {
    TEMPLATE = "template0";
    LC_COLLATE = "C";
    LC_CTYPE = "C";
    ENCODING = "UTF8";
    OWNER = "vaultwarden";
  };
  clan.core.postgresql.databases.vaultwarden.restore.stopOnRestore =
    [ "vaultwarden" ];

  clan.core = {
    vars.generators.vaultwarden = {
      files = {
        vaultwarden-admin = { };
        vaultwarden-admin-hash = { };
      };

      runtimeInputs = with pkgs; [
        coreutils
        pwgen
        libargon2
        openssl
      ];
      script = ''
        ADMIN_PWD=$(pwgen 16 -n1 | tr -d "\n")
        ADMIN_HASH=$(echo -n "$ADMIN_PWD" | argon2 "$(openssl rand -base64 32)" -e -id -k 65540 -t 3 -p 4)

        config="
        ADMIN_TOKEN=\"$ADMIN_HASH\"
        "
        echo -n "$ADMIN_PWD" > "$out"/vaultwarden-admin
        echo -n "$config" > "$out"/vaultwarden-admin-hash
      '';
    };
  };
  systemd.services.vaultwarden = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    environmentFile =

      config.clan.core.vars.generators.vaultwarden.files.vaultwarden-admin-hash.path;
    config = {
      DATABASE_URL = "postgresql:///vaultwarden";
      # "postgresql://";
      DOMAIN = "https://${cfg.domain}";
      ENABLE_WEBSOCKET = true;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
  };

  networking.exposedServices.vaultwarden = {
    port = config.services. vaultwarden.config.ROCKET_PORT;
    additionalCfg = {proxyPass, ...}: {
      locations."/notifications/hub" = {
        inherit proxyPass;
        proxyWebsockets = true;
      };
      locations."/notifications/hub/negotiate" = {
        inherit proxyPass;
        proxyWebsockets = true;
      };
    };
  };
}
