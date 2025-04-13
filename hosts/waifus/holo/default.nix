{
  specialArgs = { };
  modules = [
    ({ inputs, ... }: {
      importer = {
        inputs = {
          homeImport.enable = true;
          impermanance.enable = true;
          stylix.enable = true;
        };
      };
      nixpkgs.pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config = {
          allowBroken = true;
          allowUnfree = true;
        };

        overlays = [ inputs.self.overlays.default ];
      };
      common.specialUser = "steryy";
      services.desktopManager.plasma6.enable = true;
      fileSystems."/persist".neededForBoot = true;
      persistence = {
        rollbacks.btrfs.enable = true;
        device = "/dev/mapper/luksRoot";
      };
    })
  ];
}
