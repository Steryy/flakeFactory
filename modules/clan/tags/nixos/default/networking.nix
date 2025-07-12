{ lib, config, ... }: {

  options = {
    networking = {
      domains = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };
  config = {
    networking.nameservers = [  "1.1.1.1" ];
    services.resolved.enable = false;
  };

}
