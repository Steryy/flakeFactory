{
  config,
  lib,
  ...
}: let
  clanM = config.haumea.clan;
  inherit (lib.local.tags) toInventory getAll groups;
  allTags = getAll config.flake.clan.inventory.machines;
  toInv = toInventory allTags;
in {
 flake. clan.inventory.instances =
    (lib.mapAttrs' (n: v: {
        name = "import-tag-${n}";
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
      clanM.tags)
    // (lib.mapAttrs' (n: v: {
        name = "import-group-${n}";
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
              toInv groups."${n}";
          };
        };
      })
      clanM.groups)
    // {
      import-all = {
        module = {
          name = "importer";
          input = "clan-core";
        };
        roles.default = {
          tags.all = {};
          extraModules = [
            {
              clan.core.settings.state-version.enable = true;
              clan.inventory.machines = config.flake.clan.inventory.machines;
            }
          ];
        };
      };
    };
}
