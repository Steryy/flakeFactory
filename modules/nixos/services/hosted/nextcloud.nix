{ config, ... }:
let hostname = "nextcloud.${config.networking.domain}";
in {
  config = {
    age.secrets = { "nextcloudAdmin" = { }; };
    networking.exposedServices.nextcloud = { port = 11000; };
    services.nextcloud = {
      enable = true;
      hostName = hostname;
      config.adminpassFile = config.age.secrets."nextcloudAdmin".path;
      settings.trusted_domains =
        map (x: "nextcloud.${x}") config.networking.domains;
      settings = {
        overwriteprotocol = "https";
        trusted_proxies = [ "127.0.0.1" ];
      };
      extraAppsEnable = true;
    };
    services.nginx.virtualHosts."${hostname}".listen = [{
      addr = "127.0.0.1";
      port = config.exposedServices.nextcloud.port;
    }];
  };
}
