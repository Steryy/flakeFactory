{
  lib,
  options,
  osConfig,
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
      programs.hyprlock.enable = true;

      stylix.targets.hyprpaper.enable = lib.mkForce false;
    })
  ];
}
