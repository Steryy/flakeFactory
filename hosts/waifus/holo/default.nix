let adminUser = "myuri";
in {
  deploy = { inherit adminUser; };
  modules = [
    ./disko.nix

    {

      importer = {
        common.readOnlypkgs.enable = false;
        inputs = {
          homeImport.enable = true;
          impermanance.enable = true;
          stylix.enable = true;
          matugen.enable = true;
        };
      };
    }
    ({ inputs, system, config, flakeRoot, ... }: {
      nixpkgs.hostPlatform = "x86_64-linux";
      nixpkgs.config = {
        allowBroken = true;
        allowUnfree = true;
      };

      # nixpkgs.pkgs = import inputs.nixpkgs {
      #   system = "x86_64-linux";
      #   config = {
      #     allowBroken = true;
      #     allowUnfree = true;
      #   };
      #
      #   # overlays = [ inputs.self.overlays.default ];
      # };

      # clan.user-password.user = "alice";

      clan.user-password.user = adminUser;

      # common.specialUser = "steryy";
      services.desktopManager.plasma6.enable = true;
      fileSystems."/persist".neededForBoot = true;
      persistence = {
        rollbacks.btrfs.enable = true;
        device = "/dev/mapper/luksRoot";
      };

    })
  ];
}
