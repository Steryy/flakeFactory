{
  inputs,
  config,
  lib,
  ...
}: let
  nixModules = config.haumea.clan.tags or {};
  inherit (lib.local.tags) toInventory getAll groups;
  allTags = getAll config.clan.inventory.machines;
  toInv = toInventory allTags;
  inherit (lib.local.keys) fileFromGroup;
in {
  clan = {
    inventory = {
      instances =
        {
          zt = {
            module = {
              name = "zerotier";
              input = "clan-core";
            };
            roles.peer.tags.all = {};
            roles.moon.machines ={};
            roles.controller.machines.shou-jeannette = {
              settings = {
                allowedIps = [];
              };
            };
          };
        }
        // (lib.mapAttrs' (n: v: {
            name = "import-${n}";
            value = {
              module = {
                name = "importer";
                input = "clan-core";
              };
              roles.default = {
                extraModules =
                  lib.collect (x: lib.isPath x)
                  (lib.filterAttrs (n: _: (n == "required") || n == "default") v);
                tags =
                  toInv [n];
              };
            };
          })
          nixModules)
        // {
          import-server = {
            module = {
              name = "importer";
              input = "clan-core";
            };
            roles.default = {
              tags = toInv (groups.server);
              extraModules = with inputs.srvos.nixosModules; [
                server
                mixins-telegraf
              ];
            };
          };
          import-desktop = {
            module = {
              name = "importer";
              input = "clan-core";
            };
            roles.default = {
              tags = toInv (groups.desktop);
              extraModules = with inputs.srvos.nixosModules; [
                desktop
                mixins-systemd-boot
                mixins-nix-experimental
              ];
            };
          };
          import-all = {
            module = {
              name = "importer";
              input = "clan-core";
            };
            roles.default = {
              tags.all = {};
              extraModules = [
                ../../options.nix
                {
                  clan.inventory.machines = config.clan.inventory.machines;
                }
              ];
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
