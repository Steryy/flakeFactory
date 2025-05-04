let
  name = "extraInputs";
  dir = ./_inputs;
in {
  partitions."${name}" = {
    extraInputsFlake = dir;
  };
}
