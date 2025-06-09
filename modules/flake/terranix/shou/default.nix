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
        resource = {
          aws_key_pair = forRegions (region: {
            name = "default-${region}";
            value = {
              key_name = "shou";
              provider = "aws.${region}";
              public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdo5NQApszwHbzHhN1JxxulAa3YM9m2pDHhwfuFA78o (none)";
            };
          });
          aws_security_group = forRegions (region: {
            name = "ssh-${region}";
            value = {
              name = "Allow ssh";
              provider = "aws.${region}";
              description = "Open ssh port";
              lifecycle = [{create_before_destroy = true;}];
              ingress = [
                {
                  description = "SSH";
                  from_port = 22;
                  to_port = 22;
                  protocol = "tcp";
                  cidr_blocks = ["0.0.0.0/0"];
                  ipv6_cidr_blocks = ["::/0"];
                  prefix_list_ids = [];
                  security_groups = [];
                  self = false;
                }
              ];
              egress = [
                {
                  description = "Allow all outbound";
                  from_port = 0;
                  to_port = 0;
                  protocol = "-1";
                  cidr_blocks = ["0.0.0.0/0"];
                  ipv6_cidr_blocks = ["::/0"];
                  prefix_list_ids = [];
                  security_groups = [];
                  self = false;
                }
              ];
            };
          });
        };
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
