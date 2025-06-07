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
  clan.core.enableRecommendedDefaults = false;
  networking.hostName = lib.mkForce "";

  xdg = {
    mime.enable = false;
    icons.enable = false;
    autostart.enable = false;
    sounds.enable = false;
    terminal-exec.enable = false;
    portal.enable =
      false;
  };
}
