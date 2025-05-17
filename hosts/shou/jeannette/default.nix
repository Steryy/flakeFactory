let
  adminUser = "ruler";
in {
  deploy = {inherit adminUser;};
  importer = {
    common = {
      readOnlypkgs.enable = false;
      autoMountLuks.enable = false;
      networking.enable = false;
      profiles = {
        avahi.enable = false;
        shells.enable = false;
        direnv.enable = false;
        systemdboot.enable = false;
      };
      packages.enable = false;
    };
  };
  modules = [
    {
      fonts.fontconfig.enable =false;
    }
    ({
      inputs,
      ...
    }: {
      config = {
        zramSwap.enable = true;
        nixpkgs.pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
        };
      };
    })
  ];
}
