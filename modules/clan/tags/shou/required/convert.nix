{
  extraInputs,
  lib,
  hostName,
  ...
}: {
  imports = [
    extraInputs.nixos-generators.nixosModules.amazon
  ];
  security.sudo.execWheelOnly = lib.mkForce false;
  networking.hostName = lib.mkForce "";
  boot.loader.grub.enable =  lib.mkForce true ;
  boot.loader.systemd-boot.enable  =  lib.mkForce false ;
}
