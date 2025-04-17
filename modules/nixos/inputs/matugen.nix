{ inputs, pkgs, ... }: {
  imports = [ inputs.matugen.nixosModules.matugen ];

  programs.matugen = {
    enable = true;
    jsonFormat = "rgb";
    package = with pkgs; matugen;
  };
}
