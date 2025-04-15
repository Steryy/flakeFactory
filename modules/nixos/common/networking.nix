{ lib, config, ... }: {

  options = {
    networking = {
      domains = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      exposedServices = lib.mkOption {
        default = { };
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            port = lib.mkOption {
              default = null;
              type = lib.types.nullOr (lib.types.int);
            };

            host = lib.mkOption {
              default = "localhost";
              type = lib.types.str;
            };
          };
        });
      };
    };
  };

  config = {
    networking = {
      firewall.allowedTCPPorts = builtins.filter (x: x != null)
        (map (x: if x.host == "localhost" then x.port else null)
          (builtins.attrValues config.networking.exposedServices));
    };
  };

}
