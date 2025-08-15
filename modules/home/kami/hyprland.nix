{
  lib,
  options,
  osConfig,
  config,
  ...
}: {
  config = lib.mkMerge [
    {
      wayland.windowManager.hyprland = {
        enable = true;
        package = lib.mkIf osConfig.programs.hyprland.enable null;
        portalPackage = lib.mkIf osConfig.programs.hyprland.enable null;
        systemd.enable = lib.mkIf osConfig.programs.hyprland.withUWSM false;
      };
    }
    (lib.optionalAttrs (options ? "stylix") {
      wayland.windowManager.hyprland.settings.
        plugin.dynamic-cursors.rotate.length = config.stylix.cursor.size;
      programs.hyprlock.enable = true;

      stylix.targets.hyprpaper.enable = lib.mkForce false;
    })
  ];
}
