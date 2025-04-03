{
  config,
  options,
  lib,
  ...
}: let
in {
  config = lib.optionalAttrs (options ? "age") {
    age = {
      secrets = {
        tailscaleAuth = {};
      };
    };
    services.tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile =
        config.age.secrets.tailscaleAuth.path;
      authKeyParameters = {
        preauthorized = true;
        ephemeral = true;
      };
      extraUpFlags = [
      ];
    };
  };
}
