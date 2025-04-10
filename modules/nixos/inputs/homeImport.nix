{
  inputs,
  config,
  lib,
  flakeRoot,
  homeModules,
  ...
}: let
  hn = config.networking.hostName;
  dir = flakeRoot + "/homes";

  importer = file: x: let
    classImports = class: let
      modules = homeModules."${class}" or {};
    in
      lib.optionalAttrs (modules != {}) {
        importer."${class}" = lib.mapAttrsRecursive (_: _: lib.mkDefault true) modules;
      };
    foru =
      if lib.pathExists file
      then file
      else {};
    evaled =
      (lib.evalModules {
        modules = [
          foru

          (classImports "common")
          (classImports "${x.class}")
          {
            options.importer =
              lib.mapAttrsRecursive (
                path: _: let
                in
                  lib.mkEnableOption ""
              )
              homeModules;
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
      map (x: lib.getAttrFromPath x.path homeModules)
      (
        lib.filter (x: x.value == fe) toPe
      );
  in {
    imports =
      tmpfunc true
      ++ [
        {
          options.importer =
            lib.mapAttrsRecursive (
              path: _: let
              in
                lib.mkEnableOption ""
            )
            homeModules;
          config.importer = evaled.importer;
        }
      ];
    disabledModules = tmpfunc false;
  };

  users = lib.pipe dir [
    builtins.readDir
    (lib.filterAttrs (_: v: v == "directory"))
    (lib.mapAttrs (n: _: dir + "/${n}"))
    (lib.mapAttrs (_: builtins.readDir))
    (lib.mapAttrs (_: lib.filterAttrs (_: v: v == "directory")))
    (lib.mapAttrs (user:
      lib.filterAttrs (
        n: _: let
          hos = lib.removeSuffix ".nix" n;
        in
          hos
          == hn
          && lib.pathExists "${dir}/${user}/${hn}/default.nix"
      )))
    (lib.filterAttrs (_: v: v != {}))
    (
      lib.mapAttrs (n: _: {
        imports = [
          {
            _module.args = {
              user = config.users.users."${n}" or {};
            };
          }
          (importer "${dir}/${n}/${hn}/importer.nix" {class = "waifus";})
          {
            home = lib.mkDefault {
              username = n;
              homeDirectory = "/home/${n}";
              stateVersion = "25.05";
            };
          }
          "${dir}/${n}/${hn}/default.nix"
        ];
      })
    )
  ];
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  config = {
    home-manager = {
      inherit users;
    };
  };
}
