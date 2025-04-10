{ config, lib, ... }: {
  systemd.services."acme-fixperms".wants = [ "bind.service" ];
  systemd.services."acme-fixperms".after = [ "bind.service" ];
  age.secrets = {
    "acme.env" = { };

  };
  security.acme = {
    acceptTerms = true;
    certs = lib.pipe (config.networking.domains or [ ]) [
      (map (u: {
        name = u;
        value = {
          domain = "${u}";
          extraDomainNames = [ "*.${u}" ];
          dnsPropagationCheck = true;
          environmentFile = "${config.age.secrets."acme.env".path}";
        };
      }))
      lib.listToAttrs
    ];
  };
}
