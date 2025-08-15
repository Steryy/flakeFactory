{
  lib,
  options,
  config,
  ...
}: let
  f = config.stylix.fonts;
in {
  programs.caelestia.settings = lib.mkMerge [
    {
      appearance = {
        anim = {durations = {scale = 1;};};
        font = {
          family = lib.optionalAttrs (options ? "stylix") {
            material = f.emoji;
            mono = f.monospace;
            sans = f.sansSerif;
          };
          size = {scale = 1;};
        };
        padding = {scale = 1;};
        rounding = {scale = 1;};
        spacing = {scale = 1;};
        transparency = {
          base = 0.85;
          enabled = true;
          layers = 0.4;
        };
      };
      background = {
        desktopClock = {enabled = true;};
        enabled = true;
      };

      bar = {
        dragThreshold = 20;
        entries = [
          {
            enabled = true;
            id = "logo";
          }
          {
            enabled = true;
            id = "workspaces";
          }
          {
            enabled = true;
            id = "spacer";
          }
          {
            enabled = false;
            id = "activeWindow";
          }
          {
            enabled = true;
            id = "spacer";
          }
          {
            enabled = true;
            id = "tray";
          }
          {
            enabled = true;
            id = "clock";
          }
          {
            enabled = true;
            id = "statusIcons";
          }
          {
            enabled = true;
            id = "power";
          }
        ];
        persistent = true;
        showOnHover = true;
        status = {
          showAudio = true;
          # showBattery = true;
          # showBluetooth = true;
          # showKbLayout = false;
          # showNetwork = true;
        };
        tray = {
          background = false;
          recolour = false;
        };
        workspaces = {
          # activeIndicator = true;
          activeLabel = null;
          activeTrail = true;
          label = null;
          occupiedBg = true;
          occupiedLabel = null;
          # perMonitorWorkspaces = true;
          # rounded = true;
          showWindows = false;
          # shown = 5;
        };
      };

      border = {
        rounding = 25;
        thickness = 10;
      };
      dashboard = {
        dragThreshold = 50;
        enabled = true;
        mediaUpdateInterval = 500;
        showOnHover = true;
        visualiserBars = 45;
      };

      general = {
        apps = {
          audio = ["pavucontrol"];
          terminal = ["foot"];
        };
      };

      launcher = {
        actionPrefix = ">";
        dragThreshold = 50;
        enableDangerousActions = false;
        maxShown = 8;
        maxWallpapers = 9;
        useFuzzy = {
          actions = false;
          apps = false;
          schemes = false;
          variants = false;
          wallpapers = false;
        };
        vimKeybinds = false;
      };
      lock = {recolourLogo = false;};

      notifs = {
        actionOnClick = true;
        # clearThreshold = 0.3;
        # defaultExpireTimeout = 5000;
        # expandThreshold = 20;
        expire = true;
      };
      osd = {hideDelay = 2000;};
      paths = {
        # mediaGif = "root:/assets/bongocat.gif";
        # sessionGif = "root:/assets/kurukuru.gif";
        wallpaperDir = let
          vars = config.home.sessionVariables;
        in
          lib.mkIf (vars  ? "XDG_WALLPAPERS_DIR") vars.XDG_WALLPAPERS_DIR;
      };

      services = {
        audioIncrement = 0.1;
        smartScheme = true;
        useFahrenheit = false;
        useTwelveHourClock = false;
        weatherLocation = "10,10";
      };
      session = {
        commands = {
          hibernate = ["systemctl" "hibernate"];
          logout = ["loginctl" "terminate-user" ""];
          reboot = ["systemctl" "reboot"];
          shutdown = ["systemctl" "poweroff"];
        };
        dragThreshold = 30;
        vimKeybinds = false;
      };
    }
  ];
}
