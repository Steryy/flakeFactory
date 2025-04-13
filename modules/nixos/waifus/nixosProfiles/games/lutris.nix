{ pkgs, ... }:
let
in {
  environment.systemPackages = with pkgs; [
    (lutris.override {
      extraPkgs = pkgs: [
        # List package dependencies here

        wine
        winetricks
        protontricks
        vulkan-tools
      ];
      extraLibraries = pkgs:
        [
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
