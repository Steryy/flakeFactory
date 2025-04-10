{ config, ... }: {
  config = {
    age.secrets = { "vaultwarden.env" = { }; };
    networking.exposedServices.vaultwarden = {
      port = config.vaultwarden.config.ROCKET_PORT;
    };
    services.vaultwarden = {
      enable = true;
      environmentFile = config.age.secrets."vaultwarden.env".path;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
      };
    };
  };
}
