{
  lib,
  config,
  ...
}: let
  machines = lib.pipe config.clan.inventory.machines [
    (lib.filterAttrs (_: v: lib.elem "shou" v.tags))
  ];

  getSpecialTag = tag: tags:
    lib.removePrefix "${tag}:"
    (lib.head (lib.filter (lib.hasPrefix "${tag}:") tags));
in {
  perSystem = {...}: {
    terranix. terranixConfigurations.terraform.modules = [
      {
        resource.aws_instance =
          lib.mapAttrs (n: v: let
            arch = getSpecialTag "arch" v.tags;
            region = getSpecialTag "region" v.tags;
          in {
            ami = "\${data.aws_ami.nixos-${arch}-${region}.id}";
            instance_type = "t2.micro";


            root_block_device = {
              volume_size = 10;
            };
            tags = {
              Name = n;
              Region = region;
              Arch = arch;
              terranix = "true";
              Terraform = "true";
            };

            provisioner.local-exec = let
              ip = "\${self.public_ip}";
            in {
              command = "clan machines update ${n}  --target-host root@${ip} --build-host $USER@localhost ";
            };
          })
          machines;
      }
    ];
  };
}
