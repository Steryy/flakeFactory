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
in {
  clan = {
    inherit specialArgs;
    machines = lib.mapAttrs (n: v:
      let tags = config.clan.inventory.machines.${n}.tags or [ ];
          user = v.deploy.adminUser or "user";
      in {
        imports = 
          v.modules  ++ [{
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
              _module.args.hostName = n;
              users.defaultUser = user;
            };
          }] ;
      }) le;

    inventory = {
      services.importer =
        lib.mapAttrs' (n: v: {
          name = lib.head (lib.splitString "-" n);
          value = {
            machines."${n}" = {
              extraModules =
                lib.pipe v.importer [
                  (lib.mapAttrsRecursiveCond (x: ! x ? "enable") (p: v: {
                    path = p;
                    enable = v.enable;
                  }))
                  (lib.collect (x: x  ? "path" && x ? "enable" && x.enable))
                  (map (x: lib.getAttrFromPath x.path nixModules))
                ];
            };
          };
        }) le;

      machines = lib.mapAttrs (n: v: let
        user = v.deploy.adminUser or "user";
      in
        {
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
