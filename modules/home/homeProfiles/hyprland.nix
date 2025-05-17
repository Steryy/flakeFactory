{
  config,
  lib,
  options,
  osConfig,
  ...
}: {
  config = lib.mkMerge [
    (lib.mkIf (options ? "persistence") {
      wayland.windowManager.hyprland.settings.source = ["${config.xdg.configHome}/hypr/monitors.conf"];
      persistence.state = {
        files = [".config/hypr/monitors.conf"];
        directories = [
          ".config/hyprpanel"
        ];
      };
    })
    {
      wayland.windowManager.hyprland = {
        enable = true;
        package = lib.mkIf osConfig.programs.hyprland.enable null;
        portalPackage = lib.mkIf osConfig.programs.hyprland.enable null;
        systemd.enable = lib.mkIf osConfig.programs.hyprland.withUWSM false;
      };
    }
    (lib.optionalAttrs (options ? "stylix") {
      programs.hyprlock.enable = true;

      stylix.targets.hyprpaper.enable = lib.mkForce false;
    })
  ];
}
