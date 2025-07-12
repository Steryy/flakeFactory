{lib, ...}:
with lib;
with types; {
  _class = "clan.service";
  manifest.name = "@local/tailscale";
  perMachine = {instances, ...}: let
    domains = lib.flatten (
      lib.mapAttrsToList (
        _: v: let
          machines =
            v.roles.headscale.machines;
        in
          lib.mapAttrsToList (
            _: v: [v.settings.domain] ++ ["${v.settings.tld}"]
          )
          machines
      )
      instances
    );
  in {
    nixosModule = {...}: {
      networking.search = domains;
      networking.domains = domains;
    };
  };
  roles.client = {
    interface = {
      options = {
        useRoutingFeatures = mkOption {
          type = enum ["client" "server" "both"];
          default = "client";
        };
        advertised-rotes = mkOption {
          type = listOf str;
          default = [];
        };
      };
    };

    # Maps over all instances and produces one result per instance.
    perInstance = {
      settings,
      machine,
      roles,
      ...
    }: {
      nixosModule = {...}: {
        imports = [
          (
            import ./client.nix {inherit settings machine roles;}
          ).nixosModule
        ];
        networking.firewall = {trustedInterfaces = ["tailscale0"];};
      };
    };
  };
  roles.headscale = {
    interface = {
      options.listeningDomain = lib.mkOption {
        type = str;
        default = "tailscale.localhost";
      };
      options.tld = lib.mkOption {type = str;};
    };
    perInstance = {
      settings,
      roles,
      ...
    }: {
      nixosModule = {...}: {
        imports = [
          (
            import ./server.nix {inherit settings machine roles;}
          ).nixosModule
        ];

        networking.exposedServices = {
          headscale = {
            port = 8087;
            nameFunc = {domain, ...}:
              if domain == settings.listeningDomain
              then domain
              else null;
            host = "127.0.0.1";
            additionalCfg = {proxyPass, ...}: {
              locations = {
                # "/metrics" = {
                #   inherit proxyPass;
                #   priority = 2;
                # };
                # "/headscale" = {
                #   extraConfig = ''
                #     grpc_pass grpc://${config.services.headscale.settings.grpc_listen_addr};
                #   '';
                #   priority = 1;
                # };
                "/" = {
                  inherit proxyPass;
                  proxyWebsockets = true;
                  extraConfig = ''
                    keepalive_requests          100000;
                    keepalive_timeout           160s;
                    proxy_buffering             off;
                    proxy_connect_timeout       75;
                    proxy_ignore_client_abort   on;
                    proxy_read_timeout          900s;
                    proxy_send_timeout          600;
                    send_timeout                600;
                  '';
                };
              };
            };
          };
        };
      };
    };
  };
}
