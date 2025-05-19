{inputs, ...}:
{
  clan = {
    inventory = {
      services = {
        user-password.default = {roles.default.tags = ["kami"];};
        state-version.default = {roles.default.tags = ["all"];};
        mycelium.default = {
          roles.peer.tags = [
            "kami"
            "villainess"
          ];

          extraModules = [
            ../../nixos/mycelium-hosts.nix
            {
              clan.mycelium-static-hosts = {
                topLevelDomain = "mc";
              };
            }
          ];
        };

        importer = {
          all.roles.default = {
            tags = ["all"];
            extraModules = [
              inputs.clan-core.clanModules.static-hosts
              {
                clan.static-hosts ={
                  topLevelDomain = "zt";
                };
                clan.core.networking.buildHost = "root@localhost";
              }
            ];
          };
          headless.roles.default = {
            tags = ["villainess" "shou" "seirei"];
            extraModules = with inputs.srvos.nixosModules; [
              server
              mixins-telegraf

              
            ];

          };
          kami.roles.default = {
            tags = ["kami"];
            extraModules = with inputs.srvos.nixosModules; [
              desktop
              mixins-systemd-boot
              mixins-nix-experimental
            ];

          };
        };
        zerotier.default = {
          roles = {
            controller.machines = [
              "shou-jeannette" 
            ];
            peer = {
              tags = [
                "kami"
                "villainess" 
              ];
            };
          };
        };
        sshd.all.roles.server = {
          tags = [ "all" ];
          extraModules = [{
            users.users.root.openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdo5NQApszwHbzHhN1JxxulAa3YM9m2pDHhwfuFA78o (none)"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEEEGCUtdHT8bYJbQTr2V+GXvuLPCAmVEKeG8+uzOVGx steryy@waifu-holo"
            ];
          }];
        };

      };
    };
  };
}
