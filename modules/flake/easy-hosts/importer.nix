{
  lib,
  config,
  inputs,
  ...
}: let
  nixModules =
    config.haumea.nixModules;
  importer = file: x: let
    classImports = class: let
      modules = nixModules."${class}" or {};
    in
      lib.optionalAttrs (modules != {}) {
        importer."${class}" = lib.mapAttrsRecursive (_: _: lib.mkDefault true) modules;
      };
    evaled =
      (lib.evalModules {
        modules = [
          file
          (classImports "common")
          (classImports "${x.class}")
          {
            options.importer =
              lib.mapAttrsRecursive (
                path: _: let
                in
                  lib.mkEnableOption ""
              )
              config.haumea.nixModules;
          }
        ];
      })
      .config;
    toPe =
      lib.collect (x: x ? "value" && x ? "path")
      (lib.mapAttrsRecursive (path: value: {
          inherit value path;
        })
        evaled.importer);
    tmpfunc = fe:
      map (x: lib.getAttrFromPath x.path config.haumea.nixModules)
      (
        lib.filter (x: x.value == fe) toPe
      );
  in {
    imports = tmpfunc true;
    disabledModules = tmpfunc false;
  };
  addModules = file: modules:
    if lib.pathExists file
    then modules
    else [];
in {
  config = {
    easy-hosts = {
      functionsList = [
        (
          x: let
            file = x._path + "/importer.nix";
            facter = x._path + "/facter.json";
            disko = x._path + "/disko.nix";
          in
            x
            // {
              modules =
                x.modules
                ++ (
                  addModules file
                  [(importer file x)]
                )
                ++ (
                  addModules disko
                  [
                    inputs.nixos-facter-modules.nixosModules.facter
                    disko
                  ]
                )
                ++ (
                  addModules facter
                  [
                    inputs.nixos-facter-modules.nixosModules.facter
                    {config.facter.reportPath = facter;}
                  ]
                );
            }
        )
      ];
    };
  };
}
