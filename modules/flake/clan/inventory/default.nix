{lib, ...}: let
  inherit (lib.local.keys) fileFromGroup;
in {
  flake.clan.inventory.instances = {

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
