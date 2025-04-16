{ lib, ... }: {
  clan = {
    inventory = {
      services = {
        user-password.default = { roles.default.tags = [ "all" ]; };

        importer = {

          # all.roles.default = {
          #   tags = [ "all" ];
          #   extraModules = [{ networking.domain = "tail4c5d3.ts.net"; }];
          # };
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
