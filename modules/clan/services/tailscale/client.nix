{
  settings,
  machine,
  roles,
  ...
}: {
  nixosModule = {lib, ...}: let
    controller = lib.head (lib.mapAttrsToList (n: v: {
      name = n;
      inherit (v) settings;
    }) (roles.headscale.machines or {}));
    rol = machine.roles;
    authKey = "/var/lib/tailscale/preAuth/pre-auth-key";
  in {
    config = lib.mkIf (! lib.elem "headscale" rol) {
      systemd.services."sshd-get-tailscale" = {
        wantedBy = ["tailscaled-autoconnect.service"];
        unitConfig = {
          ConditionPathExists = "!${authKey}";
        };
        before = ["tailscaled-autoconnect.service"];
      };
      services.tailscale = {
        enable = true;
        openFirewall = true;
        inherit (settings) useRoutingFeatures;
        authKeyFile =
          authKey;
        authKeyParameters = {
          preauthorized =
            null;
          ephemeral = null;
        };

        extraUpFlags =
          [
            "--accept-routes"
            "--login-server=https://${controller.settings.listeningDomain}"
          ]
          ++ (lib.optional (settings.advertised-rotes != [])
            "--advertise-routes=${
              lib.concatStringsSep "," settings.advertised-rotes
            }");
      };
      clan.core = {
        state.tailscale.folders = ["/var/lib/tailscale"];
      };
    };
  };
}
