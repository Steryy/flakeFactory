{
  config,
  lib,
  ...
}: let
  inherit (lib.local) terranix;
in {
  perSystem = {...}: {
    terranix.terranixConfigurations.terraform={
        extraArgs = {
          inventory = terranix config.clan.inventory "shou";
        };
      modules = [
      ({ inventory, ...}:
          let 
          inherit (inventory) regions forRegions archs;
          forRegArch = f:
            lib.listToAttrs (lib.mapCartesianProduct (x: f x) {
              arch = archs;
              region = regions;
            });
          in
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
      })
    ];
  };
  };
}
