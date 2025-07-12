{
  settings,
  roles,
  ...
}: {
  nixosModule = {
    pkgs,
    hostName,
    lib,
    ...
  }: let
    clients = lib.removeAttrs roles.client.machines [hostName];
  in {
    clan.core = {
      state.headscale.folders = ["/var/lib/headscale"];
    };

    clan.nginx.acme.email = "contact@stanley-dev.net";

    services = {
      headscale = {
        enable = true;
        port = 8087;
        settings = {
          policy.path = let
            jsonFormat = pkgs.formats.json {};
          in
            jsonFormat.generate "policy.json" {
              autoApprovers = {
                routes = lib.listToAttrs (
                  lib.flatten (
                    lib.mapAttrsToList (n: v:
                      map (x: {
                        name = x;
                        value = ["tag:host-${n}"];
                      })
                      v.settings.advertised-rotes)
                    clients
                  )
                );
              };
            };
          logtail.enabled = false;
          server_url = "https://${settings.listeningDomain}";
          dns = {
            magic_dns = true;
            base_domain = settings.tld;
            search_domains = [
              settings.listeningDomain
            ];
            nameservers.global = [
              "1.1.1.1"
            ];
          };
          # ip_prefixes = [
          #   "fd7a:115c:a1e0::/48"
          #   "100.64.0.0/10"
          # ];
        };
      };
    };
  };
}
