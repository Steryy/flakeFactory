{ pkgs, ... }:
let
in {
  programs.gamemode.enable = true;
  hardware.graphics.enable32Bit = true;
  environment.systemPackages = with pkgs; [
    (lutris.override {
      extraPkgs = pkgs: [
        umu-launcher
        # List package dependencies here

        wine
        winetricks
        protontricks
        vulkan-tools
      ];
      extraLibraries = pkgs:
        [
          umu-launcher
          # List library dependencies here
        ];
    })
    gnutls
    openldap
    libgpg-error
    freetype
    sqlite
    libxml2
    xml2
    SDL2
  ];
}
