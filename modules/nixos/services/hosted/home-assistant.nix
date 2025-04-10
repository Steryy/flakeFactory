{ pkgs, config, ... }: {
  config = {
    networking.exposedServices.home-assistant = {
      port = config.services.home-assistant.config.http.server_port;
    };
    services.home-assistant = {
      enable = true;
      openFirewall = true;
      config = {
        http = {
          trusted_proxies = [ "::1" "127.0.0.1" ];
          use_x_forwarded_for = true;
        };
        default_config = { };
      };
    };
  };
}
