{
  config,
  pkgs,
  # inputs,
  # lib,
  ...
}: let
  inherit
    (config.xdg.userDirs.extraConfig)
    XDG_SCREENSHOTS_DIR
    ;
in {
  home.packages = with pkgs; [
    xwayland-satellite
    swaynotificationcenter

    swww
  ];
  programs.waybar.enable = true;
  services.clipse = {
    enable = true;
  };
  programs.niri.enable = true;
  programs.niri.config =
    builtins.concatStringsSep "\n"
    [
      ( #kdl
        ''

          input {
              keyboard {
                  xkb {
                      layout "pl,us"
                      model ""
                      rules ""
                      variant ""
                  }
                  repeat-delay 600
                  repeat-rate 25
                  track-layout "global"
              }
              touchpad {
                  tap
                  dwt
                  natural-scroll
                  accel-speed 0.000000
              }
              mouse { accel-speed 0.000000; }
              trackpoint { off; }
              trackball { off; }
              tablet
              touch
              focus-follows-mouse max-scroll-amount="30%"
          }
        ''
      )
      (
        #kdl
        ''
          binds {
              Mod+C { close-window; }
              Mod+D { spawn "rofi" "-show" "drun"; }
              Mod+Equal { set-column-width "+10%"; }
              Mod+F { fullscreen-window; }
              Mod+H { focus-column-left; }
              Mod+J { focus-window-down; }
              Mod+K { focus-window-up; }
              Mod+L { focus-column-right; }
              Mod+Minus { set-column-width "-10%"; }
              Mod+R { switch-preset-column-width; }
              Mod+Return { spawn "foot"; }

              Mod+V  { spawn "kitty" "--class" "kittyClipboard" "-e" "clipse"; }
              Mod+S { screenshot; }
              Mod+Shift+E { quit; }
              Mod+Shift+Equal { set-window-height "+10%"; }
              Mod+Shift+H { focus-monitor-left; }
              Mod+Shift+J { focus-monitor-down; }
              Mod+Shift+K { focus-monitor-up; }
              Mod+Shift+L { focus-monitor-right; }
              Mod+Shift+Minus { set-window-height "-10%"; }
              Mod+Shift+R { switch-preset-window-height; }
              Mod+Shift+Slash { show-hotkey-overlay; }
              Mod+w { spawn "~/steryy/configs/inputs/hyprland/wallpaper.sh"; }
              Super+Alt+L { spawn "swaylock"; }
              XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"; }
              XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
          }
        ''
      )
      #kdl
      ''
        layout {
            gaps 16
            struts {
                left 0
                right 0
                top 0
                bottom 0
            }
            preset-column-widths {
                proportion 0.33333
                proportion 0.5
                proportion 0.66667
            }
            default-column-width { proportion 0.5; }
            focus-ring {
                width 4
                active-color "rgb(127 200 255)"
                inactive-color "rgb(80 80 80)"
            }
            border { off; }
            insert-hint { off; }
            center-focused-column "always"
        }
      ''
      (
        #kdl
        ''
          screenshot-path "${XDG_SCREENSHOTS_DIR}/%Y-%m-%d-%H-%M-%S.png"
          cursor {
              xcursor-theme "${config.home.pointerCursor.name}"
              xcursor-size ${toString config.home.pointerCursor.size}
          }
          hotkey-overlay
          environment { DISPLAY ":0"; }
          switch-events {
              lid-close { spawn "notify-send" "The laptop lid is closed!"; }
              lid-open { spawn "notify-send" "The laptop lid is open!"; }
          }
          spawn-at-startup "swww-daemon"
          spawn-at-startup "xwayland-satellite"
          spawn-at-startup "swaync"
        ''
      )
      #kdl
      ''

        window-rule {
            match app-id="^kitty$"
            match app-id="^foot$"
            draw-border-with-background false
        }

        window-rule {
            match app-id="^kittyClipboard$"

            open-floating true
        }
        window-rule {
            match is-window-cast-target=true
            focus-ring  {
              active-color  "#f38ba8"
              inactive-color  "#7d0d2d"
            }

            border  {
              inactive-color  "#7d0d2d"
            }

            shadow  {
              color  "#7d0d2d70"
            }

            tab-indicator  {
              active-color  "#f38ba8"
              inactive-color  "#7d0d2d"
            }
        }
        layer-rule {
            match namespace="^notifications$"
            block-out-from "screencast"
        }
        animations { slowdown 1.000000; }
      ''
    ];
  #kdl
  # programs.niri.settings = {
  #   screenshot-path = "${XDG_SCREENSHOTS_DIR}/%Y-%m-%d-%H-%M-%S.png";
  #
  #   layout = {
  #     center-focused-column = "always";
  #     # default-column-width = {proportion = 1./ 3. ;};
  #     #
  #     # preset-column-widths = [
  #     #   {proportion = 1. / 3.;}
  #     #   {proportion = 1. / 2.;}
  #     #   {proportion = 4. / 5.;}
  #     # ];
  #     border.enable = false;
  #     focus-ring.enable = true;
  #     insert-hint.enable = false;
  #   };
  #   input = {
  #     keyboard.xkb.layout = "pl,us";
  #     trackpoint.enable = false;
  #     trackball.enable = false;
  #     touchpad = {
  #       tap = true;
  #       dwt = true;
  #       natural-scroll = true;
  #       # disabled-on-external-mouse = true;
  #     };
  #     focus-follows-mouse = {
  #       enable = true;
  #       max-scroll-amount = "30%";
  #     };
  #   };
  #   environment = {
  #     DISPLAY = ":0";
  #   };
  #
  #   layer-rules = [
  #     {
  #       matches = [
  #         {namespace = "waybar";}
  #         {at-startup = true;}
  #       ];
  #       block-out-from = "screencast";
  #       # geometry-corner-radius = 12;
  #       # shadowgon = true;
  #     }
  #     {
  #       matches = [
  #         {namespace = "^notifications$";}
  #       ];
  #
  #       block-out-from = "screencast";
  #     }
  #   ];
  #   window-rules = [
  #     {
  #       matches = [{is-window-cast-target = true;}];
  #
  #       focus-ring = {
  #         active-color = "#f38ba8";
  #         inactive-color = "#7d0d2d";
  #       };
  #
  #       border = {
  #         inactive-color = "#7d0d2d";
  #       };
  #
  #       shadow = {
  #         color = "#7d0d2d70";
  #       };
  #
  #       tab-indicator = {
  #         active-color = "#f38ba8";
  #         inactive-color = "#7d0d2d";
  #       };
  #     }
  #
  #     {
  #       matches = [
  #         {app-id = "^kitty$";}
  #         {app-id = "^foot$";}
  #       ];
  #       draw-border-with-background = false;
  #     }
  #     {
  #       matches = [
  #         {
  #           app-id = "^kittyClipboard$";
  #           # at-startup = true;
  #         }
  #       ];
  #       open-floating = true;
  #     }
  #   ];
  #   spawn-at-startup = [
  #     {command = ["swww-daemon"];}
  #     {command = ["xwayland-satellite"];}
  #     {
  #       command = ["clipse" "-listen"];
  #     }
  #     {command = ["swaync"];}
  #   ];
  #   switch-events = with config.lib.niri.actions; {
  #     "lid-close".action = spawn "notify-send" "The laptop lid is closed!";
  #     "lid-open".action = spawn "notify-send" "The laptop lid is open!";
  #     # lid-close.action.spawn ="";
  #     # lid-open.action.spawn ="";
  #     # tablet-mode-on.action.spawn = ["gsettings" "set" "org.gnome.desktop.a11y.applications" "screen-keyboard-enabled" "true"];
  #     # tablet-mode-off.action.spawn = ["gsettings" "set" "org.gnome.desktop.a11y.applications" "screen-keyboard-enabled" "false"];
  #   };
  #   # switch-events.lid-close
  #   binds = with config.lib.niri.actions; let
  #     sh = spawn "sh" "-c";
  #   in {
  #     "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
  #     "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
  #
  #     "Mod+C".action = close-window;
  #     "Mod+F".action = fullscreen-window;
  #     "Mod+V".action = spawn "kitty" "--class" "kittyClipboard" "-e" "clipse";
  #
  #     "Mod+Shift+E".action = quit;
  #
  #     "Mod+S".action = screenshot;
  #     "Mod+R".action = switch-preset-column-width;
  #     "Mod+Shift+p".action = spawn "bwm";
  #     "Mod+Shift+R".action = switch-preset-window-height;
  #     "Mod+Shift+H".action = focus-monitor-left;
  #     "Mod+Shift+J".action = focus-monitor-down;
  #     "Mod+Shift+K".action = focus-monitor-up;
  #     "Mod+Shift+L".action = focus-monitor-right;
  #     "Mod+H".action = focus-column-left;
  #     "Mod+J".action = focus-window-down;
  #     "Mod+K".action = focus-window-up;
  #     "Mod+L".action = focus-column-right;
  #
  #     "Mod+Minus".action = set-column-width "-10%";
  #     "Mod+Equal".action = set-column-width "+10%";
  #
  #     "Mod+Shift+Minus".action = set-window-height "-10%";
  #     "Mod+Shift+Equal".action = set-window-height "+10%";
  #     "Mod+Shift+Slash".action = show-hotkey-overlay;
  #     "Super+Alt+L".action = spawn "swaylock";
  #     "Mod+Return".action = spawn "foot";
  #     "Mod+w".action = spawn "~/steryy/configs/inputs/hyprland/wallpaper.sh";
  #
  #     "Mod+D".action = spawn "rofi" "-show" "drun";
  #   };
  # };
}
