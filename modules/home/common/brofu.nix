{ lib, config, ... }:
let
  cfg = config.programs.ashell;
  moduleType = lib.mkOption {
    type = lib.types.enum [
      "AppLauncher"
      "Updates"
      "Clipboard"
      "Workspaces"
      "WindowTitle"
      "SystemInfo"
      "KeyboardLayout"
      "KeyboardSubmap"
      "Tray"
      "Clock"
      "Privacy"
      "MediaPlayer"
      "Settings"
    ];
  };
in {

  options.programs.ashell = {
    enable = lib.mkEnableOption "enable ashell";
    config = {
      logLevel = lib.mkOption {
        type = lib.types.enum [ "DEBUG" "INFO" "WARN" "ERROR" ];
        default = "WARN";
      };
      outputs = lib.mkOption {
        type = lib.types.str;
        default = "All";
      };
      position = lib.mkOption {
        type = lib.types.enum [ "Top" "Bottom" ];
        default = "Top";
      };
      # modules = {
      #   left = [ "Workspaces" ];
      #   center = [ "WindowTitle" ];
      #   right = [ "SystemInfo" [ "Clock" "Privacy" "Settings" ] ];
      # };
      appLauncherCmd = lib.mkOption {
        type = lib.types.str;
        default = "~/.config/rofi/launcher.sh";
      };
      clipboardCmd = lib.mkOption {
        default = "cliphist-rofi-img | wl-copy";
        type = lib.types.str;
      };
      updates = lib.mapAttrs (_: _:
        lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        }) {
          checkCmd = "checkupdates; paru -Qua";
          updateCmd = ''
            alacritty -e bash -c "paru; echo Done - Press enter to exit; read" &'';
        };
      # truncateTitleAfterLength = 150;
      # workspaces = {
      #   visibilityMode = "All";
      #   enableWorkspaceFilling = false;
      # };
      system = lib.mapAttrs (n: v:
        lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = v;
        }) {
          cpuWarnThreshold = 60;
          cpuAlertThreshold = 80;
          memWarnThreshold = 70;
          memAlertThreshold = 85;
          tempWarnThreshold = 60;
          tempAlertThreshold = 80;
        };
      clock = {
        format = lib.mkOption {
          default = "%a %d %b %R";
          type = lib.types.str;
        };
      };
      mediaPlayer = {
        maxTitleLength = lib.mkOption {
          type = lib.types.int;
          default = 100;
        };
      };
      settings = lib.mapAttrs (_: _:
        lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        }) {
          lockCmd = "hyprlock &";
          audioSinksMoreCmd = "pavucontrol -t 3";
          audioSourcesMoreCmd = "pavucontrol -t 4";
          wifiMoreCmd = "nm-connection-editor";
          vpnMoreCmd = "nm-connection-editor";
          bluetoothMoreCmd = "blueman-manager";
        };
      appearance = lib.mapAttrs (_: v:
        lib.mkOption {
          type =
            lib.types.either (lib.types.listOf lib.types.str) lib.types.str;
          default = v;
        }) {
          backgroundColor = "#1e1e2e";
          primaryColor = "#fab387";
          secondaryColor = "#11111b";
          successColor = "#a6e3a1";
          dangerColor = "#f38ba8";
          textColor = "#f38ba8";
          workspaceColors = [ "#fab387" "#b4befe" ];
          specialWorkspaceColors = [ "#a6e3a1" "#f38ba8" ];
        };
    };
  };
  config = lib.mkIf cfg.enable {
    home.file."${config.xdg.configHome}".text = builtins.toTOML cfg.config;
  };

}
