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
  nixModules = config.haumea.nixModules
    // {
      tags = config.haumea.clan.tags ;
    }
    ;
  homeModules = config.haumea.homeModules;

  specialArgs = { inherit flakeRoot inputs homeModules; 
    lib = lib;
    extraInputs = config.partitions.extraInputs.extraInputs; };
  desktop=["kami"];
in {
  options.clan.hosts = lib.mkOption {
    type = lib.types.attrs ;
    default = lib.mapAttrs (_: v: v.tags) le ;

  };
  config = {

  
  clan = {
    inherit specialArgs;
    machines = lib.mapAttrs (n: v:
      let tags = config.clan.inventory.machines.${n}.tags or [ ];
          user = v.deploy.adminUser or "user";

          impr = enable:
            lib.pipe v.importer [
              (lib.mapAttrs (nam: lib.filterAttrs (tag: _:
                  let 
                    y = if nam == "tags" then
                      lib.elem tag tags
                    else true;

                  in
                lib.warnIfNot y "To import machine ${n} must be tagged with ${tag}" y
                )))
              (lib.mapAttrsRecursiveCond (x: ! x ? "enable") (p: v: {
                path = p;
                enable = v.enable;
              }))

              (lib.collect (x: x  ? "path" && x ? "enable" && x.enable == enable))

              (lib.filter (x: 
                let
                  y = if (lib.elemAt x.path 0 == "tags") then 
                        (lib.elemAt x.path 2 != "required")
                      else true;
                in 
                  lib.throwIfNot y "Required cannot be imported ${n}" y
              ))

              (lib.filter (x:  lib.hasAttrByPath x.path nixModules ))
              (map (x: lib.getAttrFromPath x.path nixModules))
            ];
          disabledModules = impr false;

          extraModules =
            (impr true)
            ++ 
            lib.optional (lib.length  disabledModules  >0 )
              {
              inherit disabledModules;
              }
            ;
      in {
        imports = 
          v.modules  ++ extraModules ++ [{
            config = { 
              clan.inventory.tags = tags;
              _module.args.hostName = n;
              users.defaultUser = user;
            };
          }] ;
      }) le;

    inventory = {

      machines = lib.mapAttrs (n: v: let
        user = v.deploy.adminUser or "user";
      in
        {
          tags =
            v.tags
            ++ (
              if lib.any (x: lib.elem x v.tags) desktop
              then ["type:desktop"]
              else ["type:server"]
            );
          # inherit (v) tags;
        } // {
          deploy = {
            targetHost = if v ? "deploy" && v.deploy ? "targetHost" then
              v.deploy.targetHost
            else
              "${user}@${n}";
          };
        } ) le;
    };
  };
  };
}
