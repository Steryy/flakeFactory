let
  adminUser = "ruler";
in {
  deploy = {inherit adminUser;};
  importer = {
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
