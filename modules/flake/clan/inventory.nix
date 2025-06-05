{inputs,config, lib, ...}:
let
  nixModules = config.haumea.clan.tags or {};
in 
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

        };

        importer = 
          (lib.mapAttrs (n: v: {
            roles.default = {
              tags = [n];
              extraModules = 
                lib.collect (x: lib.isPath x) 
                (lib.filterAttrs (n: _: (n == "required") || n == "default"   ) v )
                ;
            };

          }) nixModules) //
          {
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
