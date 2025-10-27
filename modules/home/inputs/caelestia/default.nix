{extraInputs, ...}: let
in {
  imports = [
    extraInputs.caelestia-shell.homeManagerModules.default
    ./settings.nix
  ];

  config = {
    xdg.userDirs.extraConfig = {
      CAELESTIA_DATA = ".local/share/caelestia";
      CAELESTIA_STATE = ".local/state/caelestia";
      CAELESTIA_CONFIG = ".config/caelestia";
    };
    programs.caelestia = {
      enable = true;
      cli = {enable = true;};
    };
  };
}
