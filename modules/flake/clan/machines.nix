{ lib, flakeRoot, config, inputs, ... }:
let
  domain = "tail4c5d3.ts.net";

  l = lib // builtins;
  dir = flakeRoot + "/hosts";
  le = lib.pipe dir [
    l.readDir

    (lib.mapAttrs (n: l.filterAttrs (_: v: v == "directory")))
    (l.mapAttrs (n: _: dir + "/${n}"))
    (lib.mapAttrs (_: builtins.readDir))
    # (lib.mapAttrs (n: l.filterAttrs (_: v: v == "directory")))
    (lib.mapAttrs (tag:
      lib.mapAttrs' (n: _:
        let
          _path = dir + "/${tag}/${n}";
          imported = import (if lib.pathIsDirectory _path then
            "${_path}/default.nix"
          else
            _path);

          name = builtins.concatStringsSep "-" [ tag n ];
        in {
          inherit name;
          value = imported // {
            deploy = imported.deploy or { };
            tags = [ tag "all" ] ++ (imported.tags or [ ]);
          };
        })))
    lib.attrValues
    (map (lib.attrsets.attrsToList))
    lib.flatten

    lib.listToAttrs
  ];
  nixModules = config.haumea.nixModules;
  homeModules = config.haumea.homeModules;

  specialArgs = { inherit flakeRoot inputs homeModules; };
  eval = x:
    (import (flakeRoot + "/lib/importer.nix") { inherit lib; }).eval (x // {
      modules = (x.modules) ++ [{ _module.args = { inherit (x) tags; }; }];
      importerModules = nixModules;
      inherit specialArgs;
    });
in {
  clan = {
    inherit specialArgs;
    # specialArgs = { inherit flakeRoot inputs; };
    machines = lib.mapAttrs (n: v:
      let fe = v.importer or { };

      in if fe == { } then {
        imports = (eval v).modules;
      } else {
        imports = (eval {
          inherit (v) tags;
          modules = [ fe ];
        }).modules ++ v.modules;
      }) le;

    inventory = {
      services.importer.all.roles.default = {
        tags = [ "all" ];
        extraModules = [{
          networking.domain = domain;
          clan.core.networking.buildHost = "localhost";
        }];
      };
      machines = lib.mapAttrs (n: v:
        (lib.removeAttrs v [ "modules" ]) // {
          deploy = {
            targetHost = let user = v.deploy.adminUser or "root";
            in if v ? "deploy" && v.deploy ? "targetHost" then
              v.deploy.targetHost
            else
              "${user}@${n}.${domain}";
          };

        }) le;
    };
  };
}
