{inputs, ...}: {
  imports = with inputs.srvos.nixosModules; [
    desktop
    mixins-systemd-boot
    mixins-nix-experimental
  ];
}
