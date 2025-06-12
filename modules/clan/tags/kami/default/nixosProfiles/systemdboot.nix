{
  lib,
  pkgs,
  ...
}: {
  boot = {
    tmp.useTmpfs = true;
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    kernelModules = ["kvm-intel"];
    initrd = {
      enable = true;
      systemd.enable = true;
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
    };
  };
}
