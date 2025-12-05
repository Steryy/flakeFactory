let
  adminUser = "rose";
in {
  deploy = {inherit adminUser;};
  tags = [
    "arch:aarch64"
  ];
  importer = {
  };
  modules = [
    ({
      flakeRoot,
      inputs,
      lib,
      pkgs,
      config,
      ...
    }: {
      imports = [
        ./home-assistant
        ./disko.nix

        # "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      ];
      # nixpkgs.buildPlatform = {system = "x86_64-linux";};
      boot = {
        kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi4;
        initrd.availableKernelModules =
          [
            "usbhid"
            "usb-storage"
            "vc4"
            "pcie-brcmstb" # required for the pcie bus to work
            "reset-raspberrypi" # required for vl805 firmware to load
          ]
          ++ lib.optional config.boot.initrd.network.enable "genet";

        # Allow building kernel
        initrd.systemd.tpm2.enable = false;

        loader = {
          grub.enable = lib.mkDefault false;
          generic-extlinux-compatible.enable = lib.mkDefault true;
        };
      };

      hardware.deviceTree.filter = lib.mkDefault "bcm2711-rpi-*.dtb";

      assertions = [
        {
          assertion = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.1";
          message = "This version of raspberry pi 4 dts overlays requires a newer kernel version (>=6.1). Please upgrade nixpkgs for this system.";
        }
      ];

      hardware.firmware = [pkgs.raspberrypiWirelessFirmware];
      networking.nameservers = ["1.1.1.1"];
      # networking.interfaces."end0" = {
      #   ipv4 = {
      #     routes = [
      #       {
      #         address = "192.168.1.0";
      #         prefixLength = 24;
      #         via = "192.168.0.3";
      #       }
      #     ];
      #     addresses = [
      #       {
      #         address = "192.168.0.5";
      #         prefixLength = 24;
      #       }
      #     ];
      #   };
      # };
      # networking
      # nixpkgs.crossSystem.system = "aarch64-linux";

      nixpkgs.config = {
        allowUnfree = true;
      };
      zramSwap.enable = true;
    })
  ];
}
