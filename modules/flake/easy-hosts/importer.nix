{ lib, config, flakeRoot, ... }:
let
  nixModules = config.haumea.nixModules;
  eval = x:
    (import (flakeRoot + "/lib/importer.nix") { inherit lib; }).eval
    (x // { importerModules = nixModules; });

in { config = { easy-hosts = { functionsList = [ (x: eval x) ]; }; }; }
