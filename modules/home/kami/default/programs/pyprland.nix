{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.programs.pyprland;
in {
  options.programs.pyprland = {
    enable = lib.mkEnableOption "pyprland";
    package = lib.mkPackageOption pkgs "pyprland" {};
    settings =       lib.mkOption {
        type = lib.types.attrsOf (
        lib.types.anything // { check = x: !( lib.isFunction x) && !(lib.isPath x);  }
      );
        default = {};
      };
  };
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.exec-once = [
      "pypr"
    ];
    home = let
      pypr = ".config/hypr/pyprland.toml";
    in {
      packages = [cfg.package];
      file."${pypr}".source = pkgs.writers.writeTOML pypr (
        cfg.settings
        // {
          pyprland = {
            plugins =
              (lib.attrNames cfg.settings)
              ++ (cfg.settings.pyprland.plugins or []);
          };
        }
      );
    };
  };
}
