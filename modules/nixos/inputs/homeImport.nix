{ inputs, config, lib, flakeRoot, homeModules, class, ... }:
let
  hn = config.networking.hostName;
  dir = flakeRoot + "/homes";

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
    }) homeModules;

  defaultImport = class:
    lib.mapAttrsRecursive (path: _:
      if lib.lists.elemAt path 1 == class then {
        enable = lib.mkDefault true;
      } else
        { }) { importer = homeModules; };
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

  users = lib.pipe dir [
    builtins.readDir
    (lib.filterAttrs (_: v: v == "directory"))
    (lib.mapAttrs (n: _: dir + "/${n}"))
    (lib.mapAttrs (_: builtins.readDir))
    (lib.mapAttrs (_: lib.filterAttrs (_: v: v == "directory")))
    (lib.mapAttrs (user:
      lib.filterAttrs (n: _:
        let hos = lib.removeSuffix ".nix" n;
        in hos == hn && lib.pathExists "${dir}/${user}/${hn}/default.nix")))
    (lib.filterAttrs (_: v: v != { }))
    (lib.mapAttrs (n: _:
      let
        modules = [{
          imports = [
            {
              home = lib.mkDefault {
                username = n;
                homeDirectory = "/home/${n}";
                stateVersion = "25.05";
              };
            }
            "${dir}/${n}/${hn}/default.nix"
          ];
        }];
        importerModules = (eval {
          inherit modules;
          inherit class;
        });

      in { imports = modules ++ importerModules.modules; }))
  ];
in {
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  config = { home-manager = { inherit users; }; };
}
