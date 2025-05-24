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
  supportedSystems = [
    "x86_64"
    "aarch64"
    "riscv64"
  ];
in {
  clan = {
    inherit specialArgs;
    machines = lib.mapAttrs (n: v:
      let 
        tags = config.clan.inventory.machines.${n}.tags or [ ];
        user = v.deploy.adminUser or "user";
        os = {nixos = "linux"; darwin = "darwin"; }."${v.machineClass}";

        getArch = 
          lib.removePrefix "arch-"
          (lib.lists.findFirst (x: lib.hasPrefix "arch-" x ) null tags);
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
            imports = [
              {nixpkgs.hostPlatform = "${getArch}-${os}"  ;}
            ];
            config = { 
              
              _module.args.hostName = n;
              users.defaultUser = user;
              inherit (v) importer; };
          }];
        }).modules ++ v.modules;
      }) le;

    inventory = {
      machines = lib.mapAttrs (n: v:
        let 
          user = v.deploy.adminUser or "user";
        in {
            machineClass = v.machineClass or "nixos";

          deploy = {
            targetHost = if v ? "deploy" && v.deploy ? "targetHost" then
              v.deploy.targetHost
            else
              "${user}@${n}";
          };
            tags =
              v.tags ++
              (lib.optional 
                (!(lib.any (x: lib.elem "arch-${x}" v.tags) supportedSystems)) "arch-x86_64") ;
        } ) le;
    };
  };
}
