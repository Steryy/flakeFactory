{ lib, ... }:
with lib;
with types; {
  _class = "clan.service";
  manifest.name = "tailscale";

  # Define what roles exist
  roles.client = {
    interface = {
      # These options can be set via 'roles.client.settings'
      options.advertised-rotes = mkOption {
        type = listOf str;
        default = [ ];
      };
    };

    # Maps over all instances and produces one result per instance.
    perInstance = { settings, roles, ... }:
      let

        allControllerNames = lib.attrNames roles.headscale.machines;
        first = head allControllerNames;
        controller = roles.headscale."${first}";
      in {
        nixosModule = { config, ... }: {
          clan.core.vars.generators.tailscale = {
            prompts.authToken.description = "the root user's password";
            prompts.authToken.type = "hidden";
            prompts.authToken.persist = true;
            script = ''
              cat $prompts/authToken 
            '';
          };
          networking.firewall = {
            checkReversePath = "loose";
            trustedInterfaces = [ "tailscale0" ];
            allowedUDPPorts = [ config.services.tailscale.port ];
          };

          services.tailscale = {
            enable = true;
            openFirewall = true;
            authKeyFile =
              config.clan.core.vars.generators.tailscale.files.authToken.path;
            # config.age.secrets.tailscaleAuth.path;
            authKeyParameters = {
              preauthorized = true;
              ephemeral = true;
            };

            extraUpFlags = lib.optional (length allControllerNames == 1) [
              "--login-server=${controller.settings.publicUrl}"

            ] ++ (lib.optional (settings.advertised-rotes != [ ]) [
              "--advertise-routes=${
                lib.concatStringsSep "," settings.advertised-rotes
              }"
            ]);
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
      nixosModule = { config, pkgs, ... }: {
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
