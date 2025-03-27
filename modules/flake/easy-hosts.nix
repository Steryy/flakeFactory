{
  inputs,
  lib,
  config,
  ...
}: let
  classes = {
    waifus = {
      class = "nixos";
      arch = "x86_64";
      deployable = false;
      # deployable = true;
    };
  };
  awImp = str: type:
    str
    + (
      if type == "directory"
      then "/default.nix"
      else ""
    );

  additionalClasses = lib.mapAttrs (_: v: v.class) classes;

  dir = ../../hosts;
  conector = builtins.concatStringsSep "-";
  hosts = lib.pipe dir [
    builtins.readDir
    (lib.mapAttrs (n: _: dir + "/${n}"))
    (lib.mapAttrs (_: builtins.readDir))
    (lib.mapAttrs (
      n:
        lib.mapAttrs' (n2: value: let
          n2s = lib.removeSuffix ".nix" n2;
          imp =
            import
            (awImp "${dir}/${n}/${n2}" value);
        in {
          name = conector [n n2s];
          value =
            {
              class = n;
              inherit (classes.${n}) deployable arch;
            }
            // imp;
        })
    ))
    lib.attrValues
    (map (lib.attrsets.attrsToList))
    lib.flatten
    lib.listToAttrs
  ];
in {
  imports = [
    inputs.easy-hosts.flakeModule
  ];
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

  config.
  easy-hosts = {
    perClass = class: {};
    inherit additionalClasses hosts;
    # path = ./hosts;
  };
}
