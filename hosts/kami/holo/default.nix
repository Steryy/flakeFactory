let adminUser = "myuri";
in {
  deploy = { inherit adminUser; };

  importer = {
    inputs = {
      homeImport.enable = true;
      impermanance.enable = true;
      stylix.enable = true;
      matugen.enable = true;
    };
  };
  modules = [
    ./disko.nix
    ({  pkgs, lib, ... }: {
      nixpkgs.hostPlatform = "x86_64-linux";
      sops.age.keyFile = lib.mkForce "/persist/@state/var/lib/sops-nix/key.txt";
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
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
