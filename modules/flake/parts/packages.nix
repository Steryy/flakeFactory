{ ... }:
let
  name = "overlays";
  dir = ./_submodule/nvibu;
in {
  partitionedAttrs = {
    "${name}" = "${name}";
    # nixosConfigurations = "${name}";
  };
  partitions."${name}" = {
    extraInputsFlake = dir;
    module = { inputs, ... }: { imports = [ (dir + "/flakeModule.nix") ]; };
  };
}
