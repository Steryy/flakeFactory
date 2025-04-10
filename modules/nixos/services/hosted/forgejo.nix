{ config, lib, ... }: {

  networking.exposedServices.forgejo = {
    port = config.services.forgejo.settings.server.HTTP_PORT;
  };
  services.forgejo = {

    enable = true;
    settings = {
      server = {
        DOMAIN =
          lib.concatStringsSep "." [ "forgejo" config.networking.domain ];
      };
    };
    secrets = { };
  };
}
