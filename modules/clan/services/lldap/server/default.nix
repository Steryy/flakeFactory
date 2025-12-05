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
        imports = [./provision.nix];
        clan.core.vars.generators."ldap" = {
          prompts."password" = {
            description = "LDAP admin password";
            type = "hidden";
            persist = true;
          };

          # runtimeInputs = with pkgs; [openssl];
        };

        systemd = {
          services = {
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
