{
  lib,
  config,
  ...
}: let
  inherit (lib.local.tags) getSpecial groups;
  inherit (lib.local.terranix) regionsForCloud;
  defaultRegions = {
    shou = "eu-central-1";
    seirei = "germanywestcentral";
  };

  cloudMachines = lib.pipe config.clan.hosts [
    (lib.filterAttrs (_: v: builtins.any (x: lib.elem x v) groups.cloudProviders))
    (lib.mapAttrs (_: v: {
      type = lib.findFirst (x: lib.elem x v) null groups.cloudProviders;
      region = getSpecial "region" v;
    }))
  ];
in {
  config = {
    clan.inventory.machines =
      lib.mapAttrs (n: v: let
        def = defaultRegions."${v.type}";
      in {
        tags =
          if v.region == null
          then ["region:${def}"]
          else [];
      })
      cloudMachines;
    clan.machines =
      lib.mapAttrs (n: v: let
        reg =
          if v.region == null
          then defaultRegions."${v.type}"
          else v.region;
      in {
        assertions = [
          {
            assertion =
              lib.elem reg regionsForCloud."${v.type}";
            message = "Region ${toString v.region} is not valid for machine ${n}";
          }
        ];
      })
      cloudMachines;
  };
}
