{ inputs, config, lib, flakeRoot, homeModules, tags, ... }:
let
  hn = config.networking.hostName;
  dir = flakeRoot + "/homes";

  eval = x:
    (import (flakeRoot + "/lib/importer.nix") { inherit lib; }).eval
    (x // { importerModules = homeModules; });

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
          inherit tags;
        });

      in { imports = modules ++ importerModules.modules; }))
  ];
in {
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  config = {
    home-manager = {
      backupFileExtension = "backupe";
      sharedModules =
        [{ nix.settings.experimental-features = [ "nix-command" "flakes" ]; }];
      extraSpecialArgs = { inherit flakeRoot inputs; };
      inherit users;
    };
  };
}
