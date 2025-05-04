{ lib, flakeRoot, config, inputs, ... }:
let
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

  specialArgs = { inherit flakeRoot inputs homeModules; 
    extraInputs = config.partitions.extraInputs.extraInputs; };
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
          user = v.deploy.adminUser or "user";
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
            config = { 
              users.defaultUser = user;
              inherit (v) importer; };
          }];
        }).modules ++ v.modules;
      }) le;

    inventory = {
      services.importer.all.roles.default = {
        tags = ["all"];
        extraModules = [
          inputs.clan-core.clanModules.static-hosts
          {
            clan.core.networking.buildHost = "root@localhost";
          }
        ];
      };
      machines = lib.mapAttrs (n: v:
        let user = v.deploy.adminUser or "user";
        in {
          inherit (v) tags;
        } // {
          deploy = {
            targetHost = if v ? "deploy" && v.deploy ? "targetHost" then
              v.deploy.targetHost
            else
              "${user}@${n}";
          };

        }) le;
    };
  };
}
