{
  lib,
  config,
  inputs,
  ...
}: let
  nixpkgs = inputs.nixpkgs;
  diskoImport = file: let
    enume =
      lib.collect (x: lib.isString x)
      (lib.mapAttrsRecursive
        (p: _: builtins.concatStringsSep "." p)
        config.haumea.diskoModules);
    evaled =
      (
        lib.evalModules
        {
          specialArgs =
            config.easy-hosts.shared.specialArgs;
          modules = [
            file
            {
              options.templates = lib.mkOption {
                default = [];
                type = lib.types.listOf (
                  lib.types.submodule {
                    options = {
                      config = lib.mkOption {
                        type = lib.types.raw;
                        default = {};
                      };
                      name = lib.mkOption {
                        type =
                          lib.types.nullOr
                          (lib.types.enum
                            enume);
                        default = null;
                      };
                    };
                  }
                );
              };
              options.disko = lib.mkOption {
                type = lib.types.raw;
              };
            }
          ];
        }
      )
      .config;
  in
    if evaled.templates == []
    then {
      imports = [
        evaled.disko
      ];
    }
    else {
      imports = (
        map (
          x: {
            imports = [
              x.config
              (lib.getAttrFromPath (lib.splitString "." x.name) config.haumea.diskoModules)
            ];
          }
        )
        evaled.templates
      );
    };
  removeDash = attr:
    lib.mapAttrs (
      _: v:
        if builtins.isAttrs v
        then removeDash v
        else v
    )
    (lib.filterAttrs (n: _: !lib.hasPrefix "_" n) attr);
in {
  config = {
    easy-hosts.functionsList = [
      (
        x: let
          disko = "${x._path}/disko.nix";
        in {
          modules =
            if lib.pathExists disko
            then [
              inputs.disko.nixosModules.disko
              (diskoImport disko)
            ]
            else [];
        }
      )
    ];
  };
}
