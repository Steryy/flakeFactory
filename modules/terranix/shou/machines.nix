{
  lib,
  inventory,
  localLib,
  ...
}: let
  inherit (inventory) machines;
  inherit (localLib.tags) getSpecial;
in {
        resource.aws_instance =
          lib.mapAttrs (n: v: let

      arch = getSpecial "arch" v.tags;
      region = getSpecial "region" v.tags;
          in {
            ami = "\${data.aws_ami.nixos-${arch}-${region}.id}";
            instance_type = "t2.micro";

            provider = "aws.${region}";
            key_name = "\${aws_key_pair.default-${region}.key_name}";
            vpc_security_group_ids = [
              "\${aws_security_group.ssh-${region}.id}"
            ];

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
              command = "clan machines update ${n}  --target-host root@${ip} --build-host $USER@localhost --host-key-check none ";
            };
          })
          machines;
      }
