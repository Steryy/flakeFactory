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
  flake.clan = {
    exportsModule = {_prefix, ...}: let
      exportType = lib.head (lib.tail _prefix);
      name = lib.last _prefix;
    in {
      # imports = lib.optional (exportType == "machines") ./exports/machines.nix;
      options = {};
      imports =
        lib.optional (exportType == "instances") ./exports/services.nix;
      #   ++ (
      #     lib.optionals (exportType == "machines") ./exports/machines.nix
      #   );
    };
    inherit modules;
    specialArgs = {
      exports = config.flake.clan.exports;
    };
    meta = {name = "Operation-Snowflake";};
  };
}
