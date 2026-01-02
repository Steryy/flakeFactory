{lib, ...}: let
  inherit (lib.local.keys) fileFromGroup;
in {
  flake.clan.inventory.instances = {
    rathole = {
      module = {
        name = "@local/rathole";
        input = "self";
      };
      roles.client = {
        machines.villainess-rishe.settings = {
          services = {
            minecraft = {
              type = "tcp";
              createToken = true;
              port = 25565;
              openRemote = true;
            };
          };
        };
      };
      roles.server = {
        machines.shou-jeannette.settings = {
          hostname = "polycraft.steryy.xyz";
          openFirewall = true;
          port = 7000;
        };
      };
    };

    acme-proxy = {
      module = {
        name = "@local/acme-proxy";
        input = "self";
      };
      roles.proxy = {};
      roles.client = {};
    };

    sshd = {
      module.name = "sshd";
      roles = {
        server = {
          tags.all = {};
          extraModules = [
            {
              users.users.root.openssh.authorizedKeys.keys = fileFromGroup {
                group = "admin";
                file = "sshkey";
              };
            }
          ];
        };
      };
    };
  };
}
