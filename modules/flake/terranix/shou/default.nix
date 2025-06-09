{
  config,
  lib,
  ...
}: let
  machines = lib.pipe config.clan.inventory.machines [
    (lib.filterAttrs (_: v: lib.elem "shou" v.tags))
  ];

  getSpecialTag = tag: tags:
    lib.removePrefix "${tag}:"
    (lib.head (lib.filter (lib.hasPrefix "${tag}:") tags));
  regions = lib.pipe machines [
    lib.attrValues
    (map (x: getSpecialTag "region" x.tags))
    (lib.unique)
  ];
  archs = lib.pipe machines [
    lib.attrValues
    (map
      (x: getSpecialTag "arch" x.tags))
    lib.unique
  ];
  forRegArch = f:
    lib.listToAttrs (lib.attrsets.mapCartesianProduct (x: f x) {
      arch = archs;
      region = regions;
    });
in {
  perSystem = {...}: {
    terranix.terranixConfigurations.terraform.modules = [
      {
        provider.aws =
          map (x: {
            region = x;
            alias = x;
          })
          regions;
        data = {
          aws_ami = forRegArch ({
            arch,
            region,
          }: {
            name = "nixos-${arch}-${region}";
            value = {
              owners = ["427812963091"];
              most_recent = true;

              provider = "aws.${region}";
              filter = [
                {
                  name = "name";
                  values = ["nixos/24.11*"];
                }
                {
                  name = "architecture";
                  values = [arch];
                }
              ];
            };
          });
        };
      }
    ];
  };
}
