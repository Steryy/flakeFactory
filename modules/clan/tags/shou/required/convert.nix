{
  modulesPath,
  extraInputs,
  lib,
  hostName,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    extraInputs.nixos-generators.nixosModules.amazon
  ];
  security.sudo.execWheelOnly = lib.mkForce false;
  clan.core.enableRecommendedDefaults = false;
  networking.hostName = lib.mkForce "";
}
