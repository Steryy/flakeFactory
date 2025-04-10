{ config, lib, ... }:
let
  exposedIps =
    builtins.concatStringsSep "," config.services.tailscale.advertised-rotes;
  port = 41641;
in {
  options.services.tailscale.advertised-rotes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  config = {
    exposedServices.tailscale = { inherit port; };
    services.tailscale = {
      enable = true;
      openFirewall = true;
      inherit port;
      # useRoutingFeatures = "server";
      useRoutingFeatures = "server";
      authKeyParameters = { preauthorized = true; };
      extraUpFlags =
        lib.mkIf (config.services.tailscale.advertised-rotes != [ ])
        [ "--advertise-routes=${exposedIps}" ];
      extraSetFlags =
        lib.mkIf (config.services.tailscale.advertised-rotes != [ ])
        [ "--advertise-routes=${exposedIps}" ];
    };
  };
}
