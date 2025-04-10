{ config, ... }:
let
  name = "agenix-rekey";
  dir = ./. + "/_${name}";
in {
  flake.part = config.partitions;
  partitionedAttrs = {
    "${name}" = "${name}";
    nixosConfigurations = "${name}";
  };
  partitions."${name}" = {
    extraInputsFlake = dir;
    module = { ... }: { imports = [ (dir + "/flakeModule.nix") ]; };
  };
}
