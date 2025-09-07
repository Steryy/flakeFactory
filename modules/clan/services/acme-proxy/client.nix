{lib, ...}: {
  roles.client = {
    interface = {
      options = {
        domains = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        extraDomains = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        domainFunction = lib.mkOption {
          type = lib.types.str;
          default = "\${host}.\${domain}";
        };
      };
    };
    perInstance = {
      machine,
      roles,
      settings,
      instanceName,
      ...
    }: let
      dms = lib.listToAttrs (map (x: {
          name = x;
          value = {};
        }) (
          (import ./_helper.nix {inherit lib;}).getDomains {
            inherit settings machine instanceName;
          }
        ));
      proxies = lib.attrValues roles.proxy.machines;
    in {
      nixosModule = {
        config,
        pkgs,
        ...
      }: let
        acme = pkgs.writeShellApplication {
          name = "acme";
          text = ''
            servers=(${lib.concatMapStringsSep " " (x: ''"${x.settings.nginxDomain}"'') proxies})

            test_port() {
                nc -zv -w 5 "$1" "$2" 2>&1 | grep -q 'succeeded'
            }
            possible_servers=""
            for server in "''${servers[@]}"; do
                if test_port "$server" 80; then
                    possible_servers+=("$server")
                fi
            done
            schema="http"
            if [ -z $possible_servers  ]; then
                echo "No server responds on HTTP (port 80). Exiting..."
                exit 1
            fi
            chosen_server=""
            for server in "''${possible_servers[@]}"; do
                if test_port "$server" 443; then
                    chosen_server="$server"
                    schema="https"
                    echo "Server $chosen_server supports HTTPS (port 443)."
                    break
                fi
            done


            if [ -z "$chosen_server" ]; then
                chosen_server="''${possible_servers[$RANDOM % ''${#possible_servers[@]}]}"
                echo "No server supports HTTPS. Using random server: $chosen_server"
            fi
            json=$(jq -n \
                --arg a "$1" \
                --arg d "$3" \
                --arg t "$4" \
                --arg l "$5" \
                '{action: $a, domain: $d, token: $t, keyAuth: $l}' )

            curl -X POST "$schema://$chosen_server/lego-proxy" \
                -H "Content-Type: application/json" \
                -d "$json"

          '';
          runtimeInputs = [pkgs.jq pkgs.curl pkgs.netcat];
        };
      in {
        security.acme.defaults = {
          dnsProvider = lib.mkDefault "exec";
        };
        security.acme.certs =
          lib.mapAttrs (n: _: let
            cf = config.security.acme.certs."${n}";
          in {
            extraDomainNames = ["*.${n}"];
            environmentFile =
              lib.mkIf (
                cf.dnsProvider
                == "exec"
                && !(lib.elem machine.name (lib.attrNames roles.proxy.machines))
              )
              (
                pkgs.writeText "env" ''
                  EXEC_PATH="${lib.getExe acme}"
                  EXEC_PROPAGATION_TIMEOUT=210
                  EXEC_MODE="RAW"
                  # ICT makes the _acme-challenge record a CNAME, and by default Lego
                  # follows that CNAME and tries to update the underlying record. That's
                  # not what we want, so this disables that.
                  LEGO_DISABLE_CNAME_SUPPORT=true

                ''
              );
          })
          dms;
      };

      # nixosModule =
      #   lib.mkIf (signer != machine.name)
      #   (import ./client.nix {
      #     inherit
      #       machine
      #       lib
      #       settings
      #       ;
      #   }).nixosModule;
    };
  };
}
