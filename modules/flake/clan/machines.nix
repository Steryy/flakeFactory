{ lib, flakeRoot, config, inputs, ... }:
let
  domain = "tail4c5d3.ts.net";

  le = lib.pipe config.haumea.hosts [

    (lib.mapAttrs
      (tag: lib.mapAttrs (_: v: v // { tags = (v.tags or [ ]) ++ [ tag ]; })))
    lib.attrValues
    (map (lib.attrsets.attrsToList))
    lib.flatten

    lib.listToAttrs
  ];
  nixModules = config.haumea.nixModules;
  homeModules = config.haumea.homeModules;

  specialArgs = { inherit flakeRoot inputs homeModules; };
  eval = x:
    let modules = if lib.elem "nixos" x.tags then nixModules else null;
    in (import (flakeRoot + "/lib/importer.nix") { inherit lib; }).eval (x // {
      modules = (x.modules);
      importerModules = modules;
      inherit specialArgs;
    });
in {
  clan = {
    inherit specialArgs;
    machines = lib.mapAttrs (n: v:
      let tags = config.clan.inventory.machines.${n}.tags or [ ];
      in {
        imports = (eval {
          inherit tags;
          modules = [{
            options.clan.inventory = {
              machines = lib.mkOption {
                type = lib.types.attrs;
                readOnly = true;
                default = config.clan.inventory.machines;
              };
              tags = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                readOnly = true;
                default = tags;
              };
            };
            config = { inherit (v) importer; };
          }];
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
        let user = v.deploy.adminUser or "root";
        in {
          inherit (v) tags;
        } // {
          deploy = {
            targetHost = if v ? "deploy" && v.deploy ? "targetHost" then
              v.deploy.targetHost
            else
              "${user}@${n}.${domain}";
          };

        }) le;
    };
  };
}
