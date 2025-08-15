{lib, ...}: {
  programs.pyprland = {
    enable = true;
    settings = {
      layout_center = {
        margin = 60;
        offset = [0 30];
        next = "movefocus r";
        prev = "movefocus l";
        next2 = "movefocus d";
        prev2 = "movefocus u";
      };
      monitors = {
        # hotplug_command = "pkill swww; sleep 1 &&  swww-daemon";
        # hotplug_command =
        #   "pkill ags;  ags &"
        # ;
        placement = {
          "LG Electronics LG ULTRAWIDE" = {
            rate = 60;
            resolution = [2560 1080];
            scale = 1.00;
            rightOf = "eDP-1";
          };
          "AU Optronics 0x7AA7" = {
            rate = 90;
            resolution = [2560 1600];
            scale = 1.333333;
          };

          # monitor=eDP-1,2560x1600@90.0,0x0,1.333333
        };
      };
      shortcuts_menu = {
        entries = {
          record = [
            {
              name = "sound";
              options = ["sound" "no sound"];
            }

            {
              name = "region";
              options = ["fullscreen" "region"];
            }
            "sleep 0.2; if  [[ \"[region]\" == \"fullscreen\" ]]; then flags=\"--fullscreen\" else flags=\"\" fi; notify-send Nu  $flags " # sleep to let the menu close before the picker opens
          ];
          #   {
          #   "region (no sound)" = "~/.config/ags/scripts/record-script.sh"; # Record region (no sound)
          #   "fullscreen (no-sound)" = "~/.config/ags/scripts/record-script.sh --fullscreen"; # [hidden] Record screen (no sound)
          #   "fullscreen" = "~/.config/ags/scripts/record-script.sh --fullscreen-sound"; # Record screen (with sound)
          # };
        };
      };
      scratchpads =
        lib.mapAttrs (_: x:
          x
          // {
            excludes = "*";
          })
        {
          term = {
            animation = "fromTop";
            command = "ghostty --class=com.mitchellh.ghostty-dropterm";
            class = "com.mitchellh.ghostty-dropterm";
            lazy = true;
            size = "76% 70%";
            position = "12% 10%";
          };
          volume = {
            animation = "fromTop";
            command = "pwvucontrol";
            class = "com.saivert.pwvucontrol";
            position = "12% 10%";
            lazy = true;
            size = "40% 90%";
          };
          fileman = {
            animation = "fromBottom";
            command = "ghostty  --class=com.mitchellh.yazi  -e yazi";
            class = "com.mitchellh.yazi";
            lazy = true;
            position = "12% 10%";
            size = "76% 80%";
          };
        };
    };
  };
}
