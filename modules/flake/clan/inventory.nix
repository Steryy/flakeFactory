{
  inputs,
  config,
  lib,
  ...
}: let
  nixModules = config.haumea.clan.tags or {};
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
            roles.controller.machines.shou-jeannette = {};
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
                tags = {
                  "${n}" = {
                  };
                };
              };
            };
          })
          nixModules);
      services = {
        user-password.default = {roles.default.tags = ["kami"];};
        state-version.default = {roles.default.tags = ["all"];};
        mycelium.default = {
          roles.peer.tags = [
            "kami"
            "villainess"
          ];
        };

        importer = {
          all.roles.default = {
            tags = ["all"];
            extraModules = [
              ../../options.nix
              {
                clan.inventory.machines = config.clan.inventory.machines;
              }
            ];
          };
          type-server.roles.default = {
            tags = ["type:server"];
            extraModules = with inputs.srvos.nixosModules; [
              server
              mixins-telegraf
            ];
          };
          type-desktop.roles.default = {
            tags = ["type:desktop"];
            extraModules = with inputs.srvos.nixosModules; [
              desktop
              mixins-systemd-boot
              mixins-nix-experimental
            ];
          };
        };
        sshd.all.roles.server = {
          tags = ["all"];
          extraModules = [
            {
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdo5NQApszwHbzHhN1JxxulAa3YM9m2pDHhwfuFA78o (none)"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEEEGCUtdHT8bYJbQTr2V+GXvuLPCAmVEKeG8+uzOVGx steryy@waifu-holo"
              ];
            }
          ];
        };
      };
    };
  };
}
