{ inputs, lib, flakeRoot, config, ... }: {
  imports = [ inputs.clan-core.flakeModules.clan ];
  clan = {
    inventory = { modules = config.haumea.clanServices; };
    meta = { name = "Operation-Snowflake"; };
  };

}
