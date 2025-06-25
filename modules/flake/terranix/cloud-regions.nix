{
  lib,
  config,
  ...
}: let
  inherit (lib.local.tags) getSpecial;
  cloud = {
    shou = {
      default = "eu-central-1";
      regions = [
        "af-south-1"
        "ap-east-1"
        "ap-northeast-1"
        "ap-northeast-2"
        "ap-northeast-3"
        "ap-south-1"
        "ap-south-2"
        "ap-southeast-1"
        "ap-southeast-2"
        "ap-southeast-3"
        "ap-southeast-4"
        "ap-southeast-5"
        "ap-southeast-7"
        "ca-central-1"
        "ca-west-1"
        "cn-north-1"
        "cn-northwest-1"
        "eu-central-1"
        "eu-central-2"
        "eu-north-1"
        "eu-south-1"
        "eu-south-2"
        "eu-west-1"
        "eu-west-2"
        "eu-west-3"
        "il-central-1"
        "me-central-1"
        "me-south-1"
        "mx-central-1"
        "sa-east-1"
        "us-east-1"
        "us-east-2"
        "us-west-1"
        "us-west-2"
      ];
    };

    seirei = {
      default = "germanywestcentral";
      regions = [
        "southafricanorth"
        "southafricawest"
        "australiacentral"
        "australiacentral2"
        "australiaeast"
        "australiasoutheast"
        "centralindia"
        "eastasia"
        "japaneast"
        "japanwest"
        "jioindiacentral"
        "jioindiawest"
        "koreacentral"
        "koreasouth"
        "newzealandnorth"
        "southindia"
        "southeastasia"
        "westindia"
        "canadacentral"
        "canadaeast"
        "francecentral"
        "francesouth"
        "germanynorth"
        "germanywestcentral"
        "italynorth"
        "northeurope"
        "norwayeast"
        "norwaywest"
        "polandcentral"
        "spaincentral"
        "swedencentral"
        "switzerlandnorth"
        "switzerlandwest"
        "uksouth"
        "ukwest"
        "westeurope"
        "mexicocentral"
        "israelcentral"
        "qatarcentral"
        "uaecentral"
        "uaenorth"
        "brazilsouth"
        "brazilsoutheast"
        "brazilus"
        "centralus"
        "centraluseuap"
        "eastus"
        "eastus2"
        "eastus2euap"
        "eastusstg"
        "northcentralus"
        "southcentralus"
        "southcentralusstg"
        "westcentralus"
        "westus"
        "westus2"
        "westus3"
      ];
    };
  };

  types = lib.attrNames cloud;
  cloudMachines = lib.pipe config.clan.hosts [
    (lib.filterAttrs (_: v: builtins.any (x: lib.elem x v) types))
    (lib.mapAttrs (_: v: {
      type = lib.findFirst (x: lib.elem x v) null types;
      region = getSpecial "region" v;
    }))
  ];
in {
  options.clan.cloudLocations = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          default = lib.mkOption {
            type = lib.types.str;
          };
          regions = lib.mkOption {
            type = lib.types.listOf (
              lib.types.str
            );
          };
        };
      }
    );
    default = cloud;
  };

  config = {
    flake.cloudMachines = cloudMachines;

    clan.inventory.machines =
      lib.mapAttrs (n: v: let
        def = cloud."${v.type}".default;
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
          then cloud."${v.type}".default
          else v.region;
      in {
        assertions = [
          {
            assertion =
              lib.elem reg cloud."${v.type}".regions;
            message = "Region ${toString v.region} is not valid for machine ${n}";
          }
        ];
      })
      cloudMachines;
    clan.specialArgs = {
      cloudLocations = cloud;
    };
  };
}
