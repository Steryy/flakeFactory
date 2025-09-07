{lib, ...}: {
  roles.proxy = {
    interface = {
      options = {
        nginxDomain = lib.mkOption {
          type = lib.types.str;
        };
      };
      options.acme = lib.mkOption {
        default = {};
        type = lib.types.submodule ({config, ...}: {
          options = {
            email = lib.mkOption {
              type = lib.types.str;
            };

            # https://go-acme.github.io/lego/dns/index.html
            dnsProvider = lib.mkOption {
              type = lib.types.enum config.dnsProviders;
              # default = null;
            };

            dnsProviders = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [
                "cloudflare"
                # "digitalocean"
                # "dnsimple"
                # "dnspod"
                # "dyn"
                # "gandi"
                # "google"
                # "linode"
                # "namecheap"
                # "ovh"
                # "rfc2136"
                # "route53"
                # "sakuracloud"
                # "transip"
              ];
            };
          };
        });
      };
    };
    perInstance = {settings, ...}: {
      nixosModule = {
        config,
        pkgs,
        ...
      }: let
        package = pkgs.callPackage ./packages/lego-stripped/package.nix {inherit (settings.acme) dnsProviders;};
      in {
        systemd.services.lego-proxy = {
          environment = {
            DNS_PROVIDER = settings.acme.dnsProvider;
            SOCKET_PATH = "/run/lego-proxy.sock";
          };
          serviceConfig = {
            EnvironmentFile = config.clan.core.vars.generators.acme.files."acme.env".path;
            ExecStart = "${package}/bin/lego-proxy";
            Restart = "always";
            RestartSec = "10s";
          };
        };

        security.acme.defaults = {
          inherit (settings.acme) dnsProvider email;
        };
        security.acme.acceptTerms = true;
        services.nginx.virtualHosts."${settings.nginxDomain}" = {
          locations = {
            "/" = {
              proxyPass = "unix:${config.systemd.services.lego-proxy.environment.SOCKET_PATH}";
            };
          };
        };
        clan.core = {
          vars.generators = {
            acme = {
              prompts = {
                "acme.env" = {
                  type = "multiline";
                  description = "Put provider env vars";
                  persist = true;
                };
              };
            };
          };
        };
      };
    };
  };
}
