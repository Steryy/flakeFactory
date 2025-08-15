{ config, lib, pkgs, ... }:
let
  domain = lib.head config.networking.domains;
  hostname = "nextcloud.${domain}";
in {
  config = {
    clan.core = {
      state.nextcloud.folders = [
        config.services.nextcloud.home
        # "/var/lib/tailscale"
      ];
      vars.generators.nextcloud = {
        prompts.admin-password.type = "hidden";
        prompts.admin-password.persist = true;
        prompts.admin-password.description =
          "You can autogenerate a password, if you leave this prompt blank.";
        files.admin-password.deploy = false;
        files.admin-password-hash = { };

        runtimeInputs = [ pkgs.coreutils pkgs.xkcdpass pkgs.mkpasswd ];
        script = ''
          prompt_value=$(cat "$prompts"/admin-password)
          if [[ -n "''${prompt_value-}" ]]; then
            echo "$prompt_value" | tr -d "\n" > "$out"/admin-password
          else
            xkcdpass --numwords 3 --delimiter - --count 1 | tr -d "\n" > "$out"/admin-password
          fi
          mkpasswd -s -m sha-512 < "$out"/admin-password | tr -d "\n" > "$out"/admin-password-hash
        '';
      };
    };

    networking.exposedServices.nextcloud = {
      port = 11000;
      host = "127.0.0.1";
    };

    clan.core.postgresql.users.nextcloud = { };
    clan.core.postgresql.databases.nextcloud.create.options = {
      TEMPLATE = "template0";
      LC_COLLATE = "C";
      LC_CTYPE = "C";
      ENCODING = "UTF8";
      OWNER = "nextcloud";
    };
    clan.core.postgresql.databases.nextcloud.restore.stopOnRestore = [ "nextcloud" ];

    services.nextcloud = {
      enable = true;
      package = with pkgs; nextcloud31;
      hostName = hostname;
      home = "/var/lib/nextcloud";
      datadir = "/var/lib/nextcloud";
      https = true;
      database.createLocally = true;
      configureRedis = true;
      config = {
        dbtype = "pgsql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
        adminuser = "nextadmin";

        adminpassFile =
          config.clan.core.vars.generators.nextcloud.files.admin-password-hash.path;
      };
      maxUploadSize = "2G"; # also sets post_max_size and memory_limit
      phpOptions = { "opcache.interned_strings_buffer" = "16"; };
      settings = {
        # overwriteprotocol = "https";
        trusted_proxies = [
          config.networking.exposedServices.nextcloud.host
        ];
      };
      extraAppsEnable = true;
    };
  };
}
