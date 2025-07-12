{lib, ...}: let
  inherit (lib.local.tags) getSpecial groups;
in rec {
  regionsForCloud = {
    shou = [
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

    seirei = [
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
  getCloudType = tags:
    lib.findFirst (x: lib.elem x tags) null groups.cloudProviders;
  # lib.find (x: x != null) (map (x: checkRegion x tags) groups.cloudProviders);
  checkRegion = tags: let
    region = getSpecial "region" tags;
    type = getCloudType tags;
  in
    if region != null && type != null
    then lib.elem region regionsForCloud."${type}"
    else null;

  for_each = data: f:
    (
      f "each.key" "each.value"
    )
    // {for_each = data;};
  cloudGroups = lib.listToAttrs (
    map (name: {
      name = name;
      value = inventory: let
        machines = lib.pipe inventory.machines [
          (lib.filterAttrs (_: v: lib.elem name v.tags))
        ];
        help = tag:
          lib.pipe machines [
            lib.attrValues
            (map (x: getSpecial tag x.tags))
            (lib.filter (x: x != null))
            (lib.unique)
          ];
      in rec {
        inherit machines;
        regions = lib.filter (x: lib.elem x regionsForCloud."${name}") (help "region");
        forRegions = f: lib.listToAttrs (map (x: f x) regions);
        archs = help "arch";
        forArchs = f: lib.listToAttrs (map (x: f x) archs);
      };
    })
    groups.cloudProviders
  );
}
