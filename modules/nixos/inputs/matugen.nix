{inputs, ...}: {
  imports = [
    inputs.matugen.nixosModules.matugen
  ];

  programs.matugen = {
    enable = true;
    jsonFormat = "rgb";
  };
}
