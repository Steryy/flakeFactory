let
  ldapTld = "ldap";
  ldapDomain = "lldap.${ldapTld}";
in {
  flake.clan.inventory.instances = {
    certificates = {
      module.name = "certificates";
      roles = let
        tlds = ["postgresql" ldapTld];
      in {
        ca = {
          machines.villainess-claire = {};
          settings.tlds = tlds;
        };
        default = {
          tags.all = {};
          extraModules = [
            {
              security.acme.localtlds =
                (map (x: "account-${x}") tlds) ++ tlds;
            }
          ];
        };
      };
    };
    lldap = {
      module = {
        name = "@local/lldap";
        input = "self";
      };
      roles.client = {
        machines.kami-holo.settings = {
          ensureGroups = {};
          ensureUsers = {
            myuri = {
              email = "myuri@${ldapDomain}";
            };
          };
        };
      };
      roles.server.machines.villainess-claire = {
        settings = {
          domain = ldapDomain;
        };
      };
    };
    mc = {
      module = {
        name = "mycelium";
      };
      roles.peer.tags.all = {};
    };
  };
}
