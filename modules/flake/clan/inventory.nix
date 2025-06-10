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
          type-server.roles.default = {
            tags = [ "type:server"];
            extraModules = with inputs.srvos.nixosModules; [
              server
              mixins-telegraf
              {
                xdg = {
                  mime.enable = false;
                  icons.enable = false;
                  autostart.enable = false;
                  sounds.enable = false;
                  terminal-exec.enable = false;
                  portal.enable = false;
                };
              }
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
          tags = ["all"];
          extraModules = [
            {
              users.users.root.openssh.authorizedKeys.keys = lib.local. fileFromGroup {
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
