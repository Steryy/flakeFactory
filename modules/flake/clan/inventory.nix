{ lib, ... }: {
  clan = {
    inventory = {
      instances = {
        "tailscaleClient" = {
          module.name = "tailscale";
          roles.client = {
            tags = {
              # Right side needs to be an attribute set. Its purpose will become clear later
              all = { };
            };
            machines = {
              villainess-claire.settings = {
                useRoutingFeatures = "both";
                advertised-rotes = [ "192.168.1.30/32" "192.168.1.1/32" ];
              };
            };
          };

        };
      };
      services = {
        user-password.default = { roles.default.tags = [ "all" ]; };
        state-version.default = { roles.default.tags = [ "all" ]; };
        importer = {

          waifus.roles.default = {
            tags = [ "waifus" ];
            extraModules = [{ _module.args.system = "x86_64-linux"; }];
          };
        };
        admin.all.roles.default = {
          tags = [ "all" ];
          config.allowedKeys = lib.pipe [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdo5NQApszwHbzHhN1JxxulAa3YM9m2pDHhwfuFA78o (none)"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEEEGCUtdHT8bYJbQTr2V+GXvuLPCAmVEKeG8+uzOVGx steryy@waifu-holo"
          ] [
            (lib.lists.imap0 (name: value: {
              inherit value;
              name = toString name;
            }))
            (lib.listToAttrs)
          ];
        };

      };
    };
  };
}
