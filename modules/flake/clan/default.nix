{
  inputs,
  config,
  lib,
  ...
}: let
  modules =
    lib.mapAttrs' (n: v: {
      name = "@local/${n}";
      value = v.default or v;
    })
    config.haumea.clan.services;
in {
  imports = [inputs.clan-core.flakeModules.clan];
  clan = {
    inherit modules;
    inventory = {
      # inherit modules;
    };
    meta = {name = "Operation-Snowflake";};
  };
}
