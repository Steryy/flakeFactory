{ lib, config, flakeRoot, inputs, ... }:
let
  nixModules = config.haumea.nixModules;
  eval = x:
    (import (flakeRoot + "/lib/importer.nix") { inherit lib; }).eval
    (x // { importerModules = nixModules; });

in {
  config = {
    easy-hosts = {
      functionsList = [
        (x: eval x)
        (x:
          let facter = flakeRoot + "/vars/${x._hostName}/facter.json";
          in {
            modules = if lib.pathExists facter then [
              inputs.nixos-facter-modules.nixosModules.facter
              { config.facter.reportPath = facter; }
            ] else
              [ ];

          })
      ];
    };
  };
}
