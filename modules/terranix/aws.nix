{lib, ...}: let
  systems = ["x86_64" "arm64"];
in {
  provider = {
    aws = {
      region = "eu-central-1";
      default_tags = {
        # inherit tags;
      };
    };
  };
  data.aws_ami =

    lib.listToAttrs
    ( map (x: {
      name = "nixos_${x}";
      value = {
        owners = ["427812963091"];
        most_recent = true;
        filter = [
          {
            name = "name";
            values = ["nixos/24.11*"];
          }
          {
            name = "architecture";
            values = [x];
          }
        ];
      };
    })
    systems);
  # TODO: Add keys
  # resource.aws_key_pair.deployer = {
  #   key_name = "deployer-key";
  #   public_key = lib.fileContents ./sshkey.pub;
  # };
}
