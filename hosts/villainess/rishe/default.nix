let
  adminUser = "irmgard";
in {
  deploy = {
    targetHost = "root@192.168.1.189";
    buildHost = "localhost";
    # inherit adminUser;
  };
  importer = {
  };
  modules = [
    ({flakeRoot, ...}: {
      imports = [
        (flakeRoot + "/modules/disko/btrfs.nix")
        ./minecraft
      ];
      networking.firewall.allowedTCPPorts = [ 8080 ];
      # networking.networkd
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = true;
        publish = {
          enable = true;
          addresses = true;
          domain = true;
          hinfo = true;
          userServices = true;
          workstation = true;
        };
      };
      boot.loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
      };
      nixpkgs.config = {
        allowUnfree = true;
      };
      zramSwap.enable = true;
      disko.devices.disk.main.device = "/dev/disk/by-id/ata-WUXIN_G5_512GB_AA000000000000001400";
    })
  ];
}
