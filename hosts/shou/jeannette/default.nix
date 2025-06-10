let
  adminUser = "ruler";
in {
  deploy = {inherit adminUser;};
  importer = {
  };
  modules = [
    {
      fonts.fontconfig.enable = false;
    }
  ];
}
