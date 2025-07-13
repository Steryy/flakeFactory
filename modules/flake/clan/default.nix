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
    exportsModule = {
      options = {
        type = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
        specialExports = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.anything
          );
          default = {};
        };
        settings = lib.mkOption {
          default = {};
          type = lib.types.attrsOf (
            lib.types.anything
          );
        };
      };
    };
    inherit modules;
    inventory = {
      # inherit modules;
    };
    specialArgs = {
      exports = config.clan.exports;
    };
    meta = {name = "Operation-Snowflake";};
  };
}
