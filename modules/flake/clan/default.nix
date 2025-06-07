{ inputs,  config, ... }: {
  imports = [ inputs.clan-core.flakeModules.clan ];
  clan = {
    inventory = { modules = config.haumea.clan.services or {}; };
    meta = { name = "Operation-Snowflake"; };
  };

}
