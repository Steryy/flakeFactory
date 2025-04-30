let adminUser = "myuri";
in {
  deploy = { inherit adminUser; };

  importer = {
    common.readOnlypkgs.enable = false;
    inputs = {
      homeImport.enable = true;
      impermanance.enable = true;
      stylix.enable = true;
      matugen.enable = true;
    };
  };
  modules = [
    ./disko.nix
    ({ inputs, pkgs, ... }: {
      nixpkgs.hostPlatform = "x86_64-linux";
      nixpkgs.config = {
        allowBroken = true;
        allowUnfree = true;
      };
      services.printing = {
        enable = true;
        drivers = [
          pkgs.cnijfilter_4_00
        ];
      };
      clan.user-password.user = adminUser;
      fileSystems."/persist".neededForBoot = true;
      persistence = {
        rollbacks.btrfs.enable = true;
        device = "/dev/mapper/luksMapped";
      };

    })
  ];
}
