{
  lib,
  config,
  ...
}: let
  areas = config.services.home-assistant.registry.area;
in {
  services = {
    home-assistant = {
      extraComponents = [
        "mqtt"
        # "zha"
      ];
    };
    zigbee2mqtt = {
      enable = true;
      settings = {
        homeassistant.enabled = config.services.home-assistant.enable;
        availability = true;
        frontend = {
          port = 8080;
        };
        mqtt = {
          server = "mqtt://localhost:1883";
        };
        serial = {
          port = "/dev/ttyACM0";
          adapter = "ember";
        };
        advanced = {
          homeassistant_legacy_entity_attributes = false;
          homeassistant_legacy_triggers = false;
          legacy_api = false;
          legacy_availability_payload = false;
          log_level = "warning";
          channel = 25;
          ext_pan_id = [
            188
            195
            48
            51
            173
            30
            198
            62
          ];
          network_key = [
            215
            188
            46
            100
            72
            121
            208
            56
            217
            245
            191
            229
            213
            234
            99
            5
          ];
          pan_id = 33936;
        };
        devices = lib.mapAttrs (_: v:
          v
          // {
            homeassistant = let
              extr = lib.head (lib.split "/" v.friendly_name);
              area = areas."${extr}" or null;
            in {
              device = lib.mkIf (area != null) {
                suggested_area = area.name;
                sa = area.name;
              };
              name = lib.removePrefix "${extr}/" v.friendly_name;
            };
          }) {
          "0xe0798dfffea74e61" = {
            friendly_name = "bedroom/router";
          };
          "0x70b3d52b600c2018" = {
            friendly_name = "bedroom/desk/power";
          };
          "0xa4c1387a548c7709" = {
            friendly_name = "bedroom/ceiling/light";
          };
          "0x00124b00292b4065" = {
            friendly_name = "bedroom/door";
          };
          "0x00124b002a6d4479" = {
            friendly_name = "bedroom/air-sensor";
          };
          "0xa4c138871f908dab" = {
            friendly_name = "bedroom/desk/pir";
          };

          "0x00124b00061ff516" = {
            friendly_name = "living_room/router";
            device_options.state_action = false;
          };
          #entry
          "0xa4c138925db81b20" = {
            friendly_name = "entry/air-sensor";
          };
          # Kitchen
          "0xa4c13896d0455a5f" = {
            friendly_name = "kitchen/air-sensor";
          };
        };
      };
    };
    # TODO: Try to secure it with lldap
    mosquitto = {
      enable = true;
      listeners = [
        {
          settings = {
            allow_anonymous = true;
          };
          omitPasswordAuth = true;
          acl = ["topic readwrite #"];
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
