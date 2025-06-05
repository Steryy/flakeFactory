{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg =
    config.stylix
    or {cursor = null;};
in {
  environment.systemPackages = let
    bg = config.lib.stylix.colors.base00 or "2e3440";
  in [
    (pkgs.where-is-my-sddm-theme.override {
      themeConfig.General = {
        showSessionsByDefault = false;

        showUserRealNameByDefault = false;
        # passwordTextColor = "random";
        background = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        backgroundFill = "#${bg}";
        backgroundMode = "none";
      };
    })
  ];
  services.displayManager.sddm = lib.mkForce {
    enable = true;
    wayland = {
      enable = true;
      compositor = "kwin";
    };
    settings.Theme = lib.mkMerge [
      (lib.mkIf (cfg.cursor != null) {
        CursorTheme = cfg.cursor.name;
        CursorSize = cfg.cursor.size;
      })
    ];

    # breeze-icons
    # kirigami
    # pkgs.kirigami
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs.kdePackages; [
      # pkgs.qt5.qtbase
      # pkgs.kdePackages.qtbase
      # pkgs.qtile-unwrapped

      libplasma
      plasma5support
      qtvirtualkeyboard
      qtsvg
      qtvirtualkeyboard
    ];
    theme = "where_is_my_sddm_theme";
  };
}
