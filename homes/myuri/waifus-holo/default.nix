{ flakeRoot, ... }: {
  imports = [
    ./importer.nix
    ./_packages.nix
    ({ config, pkgs,
      # lib,
      ... }: {
        services.blueman-applet.enable = true;
        home.packages = with pkgs; [
        ];
        fonts.fontconfig.enable = true;
        programs.helix.enable = true;
      })
  ];
}
