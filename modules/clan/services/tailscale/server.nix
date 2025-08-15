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

    systemd.services.headscale-auto = {
      wantedBy = ["multi-user.target"];
      after = ["headscale.service"];

      script = "${pkgs.writeShellScript "sta" ''
        PATH="$PATH:${pkgs.headscale}/bin:${pkgs.jq}/bin"
        sleep 5
        getId(){
          user=$1
          user_id=$(headscale users ls -n "$user" -o json |   jq '.[] | .id ' )
          if [  -z "$user_id"  ]; then
            echo "User ID not found, creating user..."
            headscale users create "$user"
            user_id=$(headscale users ls -n "$user" -o json |   jq '.[] | .id ' )
          fi
          echo "$user_id"
        }

        baseDir="/var/lib/headscale/preAuth"
        mkdir -p  "$baseDir"
        ${lib.concatMapStrings (x:
          #bash
          ''
            mkdir -p "$baseDir/${x}"
            userId=$(getId "auth_user" )
            if [ ! -f  "$KEY"  ]; then
              headscale preauthkeys create --user $userId  --expiration 20d --reusable  -o json | jq -r '.key' > "$baseDir/${x}/pre-auth-key"
            fi

          '') (lib.attrNames clients)}

      ''}";
    };

    services = {
      headscale = {
        enable = true;
        port = 8087;
        # package = pkgs.headscale.overrideAttrs (old: rec {
        #   version = "0.25.0";
        #
        #   src = pkgs.fetchFromGitHub {
        #     owner = "juanfont";
        #     repo = "headscale";
        #     rev = "v${version}";
        #     hash = "sha256-5CwaPaGh0yvHwmSpbsvc4ajkW9RbYVMilNTIJxeYcIs=";
        #   };
        #
        #   vendorHash = "sha256-ZQj2A0GdLhHc7JLW7qgpGBveXXNWg9ueSG47OZQQXEw=";
        # });
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
