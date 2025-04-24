{ lib, ... }:
with lib;
with types; {
  _class = "clan.service";
  manifest.name = "tailscale";

  # Define what roles exist
  roles.client = {
    interface = {
      # These options can be set via 'roles.client.settings'
      options = {
        useRoutingFeatures = mkOption {
          type = enum [ "client" "server" "both" ];
          default = "client";
        };
        advertised-rotes = mkOption {
          type = listOf str;
          default = [ ];
        };
      };
    };

    # Maps over all instances and produces one result per instance.
    perInstance = { settings, roles, ... }:
      let

        allControllerNames = lib.attrNames (roles.headscale.machines or { });
        first = head allControllerNames;
        controller = roles.headscale."${first}";
      in {
        nixosModule = { config, ... }:
          let
            keyType =
              config.clan.core.vars.generators.tailscale.files.type.value;
          in {
            clan.core = {
              state.tailscale.folders = [ "/var/lib/tailscale" ];
              vars.generators.tailscale = {
                files = { type = { secret = false; }; };
                prompts.authToken.description = "Put tailscale key";
                prompts.authToken.type = "hidden";
                prompts.authToken.persist = true;
                script = ''
                  cut -d'-' -f1,2  < "$prompts/authToken"  | tr -d '\n' > "$out/type"
                '';
              };
            };
            networking.firewall = { trustedInterfaces = [ "tailscale0" ]; };

            services.tailscale = {
              enable = true;
              openFirewall = true;
              inherit (settings) useRoutingFeatures;
              authKeyFile =
                config.clan.core.vars.generators.tailscale.files.authToken.path;
              # config.age.secrets.tailscaleAuth.path;
              authKeyParameters = {
                preauthorized =
                  if elem keyType [ "tskey-client" ] then true else null;
                ephemeral =
                  if elem keyType [ "tskey-client" ] then true else null;
              };

              extraUpFlags = [ "--accept-routes" ]
                ++ lib.optional (length allControllerNames == 1) [
                  "--login-server=${controller.settings.publicUrl}"

                ] ++ (lib.optional (settings.advertised-rotes != [ ]) [
                  "--advertise-routes=${
                    lib.concatStringsSep "," settings.advertised-rotes
                  }"
                ]);
              # map (x: "--advertise-routes=${exposedIps}") settings.advertised-rotes;
            };

          };
      };
  };
  roles.headscale = {
    interface = {
      options.publicUrl = mkOption { type = str; };
      options.domain = mkOption { type = str; };
      options.tld = mkOption { type = str; };
      # # These options can be set via 'roles.server.settings'
      # options.dynamicIp.enable = mkOption { type = bool; };
    };
    perInstance = { settings, ... }: {
      nixosModule = { config, ... }: {
        services = {
          headscale = {
            enable = true;
            address = "0.0.0.0";
            port = 8080;
            server_url = "${settings.publicUrl}";
            dns = { baseDomain = "${settings.tld}"; };
            settings = { logtail.enabled = false; };
          };

          nginx.virtualHosts.${settings.domain} = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass =
                "http://localhost:${toString config.services.headscale.port}";
              proxyWebsockets = true;
            };
          };
        };

      };
    };
  };

}
