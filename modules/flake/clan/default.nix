{ inputs, lib, flakeRoot, config, ... }: {
  imports = [ inputs.clan-core.flakeModules.clan ];
  clan = {
    meta = {
      name = "Operation-Snowflake";

    };
  };
  flake = {
    diskoTemplates = config.haumea.diskoModules;

    # machines = lib.mapAttrs (_: v: v
    #
    # ) (lib.filterAttrs (_: v: v.machineClass == "nixos")
    #   config.clan.inventory.machines);
  };

}
