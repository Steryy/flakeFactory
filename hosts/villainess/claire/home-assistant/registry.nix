{
  lib,
  pkgs,
  config,
  ...
}: let
  nullOpt = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
  };
  stropt = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
  };
in {
  options.services.home-assistant.registry = {
    floor = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}: {
        options = {
          aliases = stropt;
          level = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
          };
          icon = nullOpt;
          name = lib.mkOption {
            type = lib.types.str;
          };
        };
      }));
      default = {};
      # default = areas;
    };
    area = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}: {
        options = {
          humidity_entity_id = nullOpt;
          temperature_entity_id = nullOpt;
          aliases = stropt;
          labels = stropt;
          picture = nullOpt;
          floor_id = nullOpt;
          icon = nullOpt;
          name = lib.mkOption {
            type = lib.types.str;
          };
        };
      }));
      default = {};
      # default = areas;
    };
  };
  config = {
    systemd.tmpfiles.settings."10-home-assistant" = let
      mkReg = name: data: idname: {
        name = "/var/lib/hass/.storage/core.${name}_registry";
        value."L+".argument = "${
          pkgs.writeText "core.${name}"
          (builtins.toJSON {
            "version" = 1;
            "minor_version" = 8;
            "key" = "core.${name}_registry";
            data = lib.mapAttrs (_:
              lib.mapAttrsToList (
                n: v:
                  v
                  // {
                    created_at = "2025-09-24T12:33:02.033583+00:00";
                    modified_at = "2025-09-24T12:33:02.033583+00:00";
                    "${idname}" = n;
                  }
              ))
            data;
          })
        }";
      };
    in
      lib.mapAttrs' (n: v: mkReg n v.data v.id)
      {
        area = {
          id = "id";
          data.areas = config.services.home-assistant.registry.area;
        };

        floor = {
          id = "floor_id";
          data.floors = config.services.home-assistant.registry.floor;
        };
      };
  };
}
