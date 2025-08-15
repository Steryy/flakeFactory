{
  lib,
  config,
  inputs,
  hostName,
  ...
}: {
  config = {
    services.nginx.enable = true;
    services.nginx.virtualHosts =
      lib.pipe
      config.networking. exposedServices
      [
        (
          lib.mapAttrsToList (
            n: v:
              map (x: let
                proxyPass = "http://${v.host}:${
                  builtins.toString
                  v.port
                }";
              in {
                name = v.nameFunc {
                  name = n;
                  domain = x;
                };
                value =
                  {
                    acmeRoot = null;
                    sslCertificate = "/var/lib/acme/${x}/fullchain.pem";
                    sslCertificateKey = "/var/lib/acme/${x}/key.pem";
                    sslTrustedCertificate = "/var/lib/acme/${x}/chain.pem";
                    forceSSL = true;
                    locations."/" = {
                      inherit proxyPass;
                      proxyWebsockets = true;
                    };
                  }
                  // (v.additionalCfg {
                    domain = x;
                    inherit proxyPass;
                  });
              })
              (
                lib.filter (x: !(lib.elem x v.excludeDomains)) config.networking.domains
              )
          )
        )
        lib.flatten
        (lib.filter (x: x.name != null))
        lib.listToAttrs
      ];
  };

  options = {
    networking = {
      exposeIp.v4 = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      exposeIp.v6 = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      exposedServices = lib.mkOption {
        default = {};
        type = lib.types.attrsOf (lib.types.submodule ({...}: {
          options = {
            nameFunc = lib.mkOption {
              default = {
                name,
                domain,
              }: "${name}-${hostName}.${domain}";
              type = lib.types.functionTo (lib.types.nullOr lib.types.str);
            };
            port = lib.mkOption {
              default = null;
              type = lib.types.nullOr (lib.types.int);
            };
            additionalCfg = lib.mkOption {
              default = _: {};
              type = lib.types.functionTo lib.types.attrs;
            };
            excludeDomains = lib.mkOption {
              default = [];
              type = lib.types.listOf lib.types.str;
            };

            host = lib.mkOption {
              default = "localhost";
              type = lib.types.str;
            };
          };
        }));
      };
    };
  };
}
