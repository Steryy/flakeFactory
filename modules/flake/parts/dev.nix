{ ... }:
let
  name = "devshell";
  dir = ./. + "/_${name}s";
in {
  partitionedAttrs = { devShells = "${name}"; };
  partitions."${name}" = {
    extraInputsFlake = dir;
    module = { ... }: {
      imports = [
        (dir + "/flakeModule.nix")

      ];
    };
  };
}
