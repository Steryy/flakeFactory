let adminUser = "francois";
in {
  deploy = { inherit adminUser; };
  importer = {
    services = {
      hosted = {
      };
    };
  };
  modules = [
    ({ inputs, pkgs, config, flakeRoot, ... }: {
      imports = [ 
        (flakeRoot + "/modules/disko/ext4.nix") 
        ./home-assistant
      ];
      clan.core.postgresql.enable = true;
      nixpkgs.hostPlatform = "x86_64-linux";
      nixpkgs.config = {
        allowUnfree = true;
      };
      boot.loader.grub.device = config.disko.devices.disk.main.device;
      disko.devices.disk.main.device =
        "/dev/disk/by-id/ata-SAMSUNG_SSD_PM871b_M.2_2280_128GB_S3U2NE0M643392";
      networking.domains = [ "home.stanley-dev.net" ];


      

    })
  ];
}
