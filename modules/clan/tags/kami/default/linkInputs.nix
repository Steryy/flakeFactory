# https://github.com/gytis-ivaskevicius/flake-utils-plus/blob/master/lib/options.nix
{
  lib,
  config,
  extraInputs,
  inputs,
  ...
}: let
  inherit (lib) mkIf filterAttrs mapAttrs'  mkEnableOption;
  mkTrueOption = description:
    (mkEnableOption description) // {default = true;};

  flakes = filterAttrs (name: value: value ? outputs) (inputs // extraInputs);

  nixRegistry =
    builtins.mapAttrs
    (name: v: {flake = v;})
    flakes;

  cfg = config.nix;
in {
  options.nix = {
    generateNixPathFromInputs = mkTrueOption "Generate NIX_PATH from available inputs.";
    generateRegistryFromInputs = mkTrueOption "Generate Nix registry from available inputs.";
    linkInputs = mkTrueOption "Symlink inputs to /etc/nix/inputs.";
  };

  config = {
    assertions = [
      {
        assertion = !cfg.generateNixPathFromInputs || cfg.linkInputs;
        message = "When using 'nix.generateNixPathFromInputs' please make sure to set 'nix.linkInputs = true'";
      }
    ];

    nix.registry =
      if cfg.generateRegistryFromInputs
      then nixRegistry
      else {self.flake = flakes.self;};

    environment.etc = mkIf (cfg.linkInputs || cfg.generateNixPathFromInputs) (mapAttrs'
      (name: value: {
        name = "nix/inputs/${name}";
        value = {source = value.outPath;};
      })
      inputs);

    nix.nixPath = mkIf cfg.generateNixPathFromInputs ["/etc/nix/inputs"];
  };
}
