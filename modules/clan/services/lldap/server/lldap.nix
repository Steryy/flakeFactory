{lib, ...}: {
  roles.server = {
    interface = {
      options = {
        domain = lib.mkOption {
          type = lib.types.str;
          description = "Ldap domain";
          default = "lldap.ldap";
        };
      };
    };
    perInstance = {settings, ...}: {
      nixosModule = {
        pkgs,
        config,
        ...
      }: {
        clan.core.vars.generators."jwt" = {
          files."ed.pem" = {};
          files."ed.pub.json" = {
            secret = false;
          };
          runtimeInputs = with pkgs; [
            openssl
            step-cli
          ];
          script = ''
            openssl genpkey -algorithm Ed25519 -out $out/ed.pem
            step crypto jwk create --from-pem=$out/ed.pem $out/ed.pub.json priv.json --no-password -f --insecure
          '';
        };
        clan.core.vars.generators."ldap" = {
          # files."jwt-secret".secret = true;
          # files."key-seed".secret = false;

          prompts."password" = {
            description = "LDAP admin password";
            type = "hidden";
            persist = true;
          };

          # script = ''
          #   openssl rand -hex 16 > $out/jwt-secret
          #   openssl rand -hex 6 > $out/key-seed
          # '';
          runtimeInputs = with pkgs; [openssl];
        };

        systemd = {
          sockets = {
            lldap-cli = {
              socketConfig = {
                Accept = true;
                MaxConnections = 10;
                ListenStream = "/run/lldap-cli.socket";
              };
              wantedBy = ["sockets.target"];
            };
          };
          services = {
            "lldap-cli@" = {
              path = with pkgs; [
                lldap-cli
                jwt-cli
                jq
              ];
              environment = {
                DURATION = "5min";
                PRIVATEKEYFILE = config.clan.core.vars.generators."jwt".files."ed.pem".path;
                ISSUER = "https:${settings.domain}";

                LLDAP_HTTPURL = "http://localhost:17170";
              };
              script =
                builtins.readFile ./ldap-proxy.sh;
            };
            lldap.serviceConfig.LoadCredential = [
              # "jwt-secret:${config.clan.core.vars.generators."ldap".files."jwt-secret".path}"
              # "key-seed:${config.clan.core.vars.generators."ldap".files."key-seed".path}"
              "password:${config.clan.core.vars.generators."ldap".files."password".path}"
            ];
          };
        };
        services.nginx = {
          virtualHosts = {
            "${settings.domain}" = {
              forceSSL = true;
              enableACME = true;
              locations = {
                "/jwt" = {
                  proxyPass = "unix://${config.systemd.sockets.lldap-cli.socketConfig.ListenStream}";
                };
                "/" = {
                  proxyPass = "http://localhost:3000";
                };
              };
            };
          };
        };
        services.lldap = {
          enable = true;
          environment = {
            # LLDAP_JWT_SECRET_FILE = "%d/jwt-secret";
            # LLDAP_KEY_SEED = "%d/key-seed";
            LLDAP_LDAP_USER_PASS_FILE = "%d/password";
          };

          # silenceForceUserPassResetWarning = true;
          settings = {
            force_ldap_user_pass_reset = "always";
            # verbose = true;
            ldap_base_dn = lib.concatMapStringsSep "," (d: "dc=${d}") (lib.splitString "." settings.domain);
            ldap_user_email = "admin@${settings.domain}";
          };
        };
      };
    };
  };
}
