{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./default-config.nix
    ./lovelace.nix
  ];
  config = {
    services.home-assistant = {
      enable = true;
      extraComponents = [
        "homeassistant_hardware"
        "met"
        "tplink"
        "wled"
      ];
      config = {
        recorder = {};
        http = {
          trusted_proxies = [
            "127.0.0.1"
            "::1"
          ];
          use_x_forwarded_for = true;
        };
        lovelace = {
          mode = "yaml";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [8123];
    networking.firewall.allowedUDPPorts = [8123];

    systemd.tmpfiles.rules = [
      "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
      "f ${config.services.home-assistant.configDir}/scenes.yaml 0755 hass hass"
      "f ${config.services.home-assistant.configDir}/secrets.yaml 0755 hass hass"
    ];
    systemd.tmpfiles.settings."10-home-assistant" = {
      "/var/lib/hass/themes".d = {
        user = "hass";
        group = "hass";
      };

    };
  };
}
