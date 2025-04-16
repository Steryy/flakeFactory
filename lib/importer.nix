{ lib, ... }: rec {

  importer = nixModules:
    lib.mapAttrsRecursive (path: v:
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

  defaultImport = nixModules: class:
    lib.mapAttrsRecursive (path: _:
      if lib.lists.elemAt path 1 == class then {
        enable = lib.mkDefault true;
      } else
        { }) { importer = nixModules; };
  eval = { tags ? [ "all" ], modules ? [ ], specialArgs ? { }
    , importerModules ? { }, ... }:
    let
      modulesToAdd = [{
        _file = __curPos.file;
        imports =
          [ (_: { options = { importer = importer importerModules; }; }) ];
      }];
      evaled = lib.evalModules {

        inherit specialArgs;
        modules = modules ++ modulesToAdd ++ [{
          config._module.check = true;
          config._module.freeformType = lib.types.unspecified;

        }] ++ (map (x:
          if x == "all" then
            (defaultImport importerModules "common")
          else
            (defaultImport importerModules x)) tags);
      };
    in {
      modules = modules ++ modulesToAdd ++ (map (x: {
        imports = [ x.path ];
        _file = x.path;
      }) (lib.collect
        (x: x ? "path" && x ? "enable" && x.enable && lib.isPath x.path)
        evaled.config.importer));

    };

}
