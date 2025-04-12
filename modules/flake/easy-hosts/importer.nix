{ lib, config, ... }:
let
  nixModules = config.haumea.nixModules;
  importer = lib.mapAttrsRecursive (path: v:
    lib.mkOption {
      default = { };
      type = lib.types.submodule ({ config, ... }: {
        options = {
          enable = lib.mkEnableOption
            ("Enable " + (lib.strings.concatStringsSep " " path));
          path = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            readOnly = true;
            default = if config.enable then v else null;

          };

        };
      });
    }) nixModules;

  defaultImport = class:
    lib.mapAttrsRecursive (path: _:
      if lib.lists.elemAt path 1 == class then {
        enable = lib.mkDefault true;
      } else
        { }) { importer = nixModules; };
  eval = x:
    let
      modulesToAdd = [
        { options = { inherit importer; }; }
        (defaultImport (x.class or ""))
        (defaultImport "common")
      ];
      evaled = lib.evalModules {

        specialArgs = x.specialArgs or { };
        modules =

          (x.modules or [ ]) ++ modulesToAdd ++ [{
            config._module.check = true;
            config._module.freeformType = lib.types.unspecified;

          }];
      };
    in {
      modules = modulesToAdd ++ [{
        imports = map (x: x.path) (lib.collect
          (x: x ? "path" && x ? "enable" && x.enable && lib.isPath x.path)
          evaled.config.importer);
      }];
    };

in { config = { easy-hosts = { functionsList = [ (x: eval x) ]; }; }; }
