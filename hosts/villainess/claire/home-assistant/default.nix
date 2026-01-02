{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./auth.nix
    ./default-config.nix
    ./lovelace.nix
    ./registry.nix
    ./waste-collection.nix
    ./mqtt.nix
    ./esphome.nix
  ];
  config = {
    services.home-assistant = {
      registry = {
        area = {
          entry = {
            name = "Entry";
            floor_id = "ground";
            icon = "mdi:door";
          };
          living_room = {
            name = "Living Room";
            floor_id = "ground";
            icon = "mdi:sofa";
          };
          bedroom = {
            name = "Bedroom";
            floor_id = "first";
            icon = "mdi:bed";
          };
          kitchen = {
            name = "Kitchen";
            icon = "mdi:food";
            floor_id = "ground";
          };
        };
        floor = {
          ground = {
            name = "Ground";
            level = 0;
          };
          first = {
            name = "First";
            level = 1;
          };
        };
      };
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

      "/var/lib/hass/themes/material_you.yaml"."L+" = {
        argument = "${pkgs.callPackage  ./packages/material-theme.nix {}}/share/material_you.yaml";
      };
    };
  };
}
