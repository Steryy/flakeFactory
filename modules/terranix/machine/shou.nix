{
  hostname,
  arch,
  ...
}: {

  resource.aws_instance."${hostname}" = {
    ami = "\${data.aws_ami.nixos_${arch}.id}";
    instance_type = "t2.micro";
    root_block_device = {
      volume_size = 10;
    };
    provisioner.local-exec = let
      ip = "\${self.public_ip}";
    in {
      command = "clan machines update ${hostname}  --target-host root@${ip} --build-host $USER@localhost ";
    };

    tags = {
      Name = hostname;
      terranix = "true";
      Terraform = "true";
    };
  };
}
