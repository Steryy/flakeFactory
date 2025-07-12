{lib, ...}: let
  inherit (lib.local.keys) fileFromGroup;
in {
  clan = {
    inventory = {
      instances = {
        zt = {
          module = {
            name = "zerotier";
            input = "clan-core";
          };
          roles.peer.tags.all = {};
          roles.moon.machines = {};
          roles.controller.machines.shou-jeannette = {
            settings = {
              allowedIps = [];
            };
          };
        };
      };
      services = {
        user-password.default = {roles.default.tags = ["kami"];};
        state-version.default = {roles.default.tags = ["all"];};

        sshd.all.roles.server = {
          tags = ["all"];
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
