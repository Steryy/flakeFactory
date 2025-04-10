{
  lib,
  config,
  ...
}: let
  cfg = config.easy-hosts;
in {
  options.easy-hosts.classesDefaults = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          class = lib.mkOption {
            type = lib.types.str;
          };
          arch = lib.mkOption {
            type = lib.types.str;
            default = "x86_64";
          };
          deployable = lib.options.mkEnableOption "deployable";
        };
      }
    );
    default = {};
  };
  config = {
    easy-hosts = {
      classesDefaults = {
        waifus = {
          class = "nixos";
          arch = "x86_64";
          deployable = false;
          # deployable = true;
        };
      };

      functionsList = [
        (
          v: (cfg.classesDefaults."${v.class}" or {})
        )
      ];
      additionalClasses =
        lib.mapAttrs (_: v: v.class)
        config.easy-hosts.classesDefaults;
    };
  };
}
