{ pkgs, config, lib, ... }:
let
  domain = lib.concatStringsSep "." [
    "home-assistant"
    (lib.head config.networking.domains)
  ];
in {
  config = {
    clan.core.state.home-assistant.folders =
      [ config.services.home-assistant.configDir ];
    networking.exposedServices.home-assistant = {
      port = config.services.home-assistant.config.http.server_port;
    };

    clan.postgresql.users.hass = { };
    clan.postgresql.databases.hass.create.options = {
      TEMPLATE = "template0";
      LC_COLLATE = "C";
      LC_CTYPE = "C";
      ENCODING = "UTF8";
      OWNER = "hass";
    };
    clan.postgresql.databases.hass.restore.stopOnRestore = [ "home-assistant" ];
    services.home-assistant = {
      enable = true;
      openFirewall = true;
      package = (pkgs.home-assistant.override {
        extraPackages = py: with py; [ psycopg2 ];
      }).overrideAttrs (oldAttrs: { doInstallCheck = false; });
      config = {
        recorder.db_url = "postgresql:///hass";
        http = {
          trusted_proxies = [ "::1" "127.0.0.1" ];
          use_x_forwarded_for = true;
        };
        default_config = { };
      };
    };

  };
}
