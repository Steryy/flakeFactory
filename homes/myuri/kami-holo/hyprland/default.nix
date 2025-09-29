{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./binds.nix
    ./env.nix
    ./pyprland.nix
  ];
  services.hyprpaper.enable = lib.mkForce false;


  wayland.windowManager.hyprland.plugins = with pkgs.hyprlandPlugins; [
    hypr-dynamic-cursors
    # hyprsplit
  ];
  wayland.windowManager.hyprland.settings = {
    plugin = {
      dynamic-cursors = {
        enabled = true;
        mode = "rotate";
      };
      # hyprsplit = {
      #   num_workspaces = 10;
      # };
    };
    xwayland = {
      force_zero_scaling = true;
      create_abstract_socket = true;
      # hidpi = true;
    };
    ecosystem = {
      no_update_news = true;
      no_donation_nag = true;
    };

    cursor = {
      # sync_gsettings_theme = true;
      # no_hardware_cursors = 2; # change to 1 if want to disable
      enable_hyprcursor = false;
      # warp_on_change_workspace = 2;
      # no_warps = true;
    };
    # source = [
    #   "$HOME/.config/hypr/hyprland/keybinds.conf"
    # ];

    # autostart
    exec-once = [
      "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment PATH"
      "wl-clip-persist --clipboard both &"
      "clipse -listen"
      # "hyprpanel &"
    ];

    input = {
      kb_layout = "pl,us";
      kb_options = "grp:alt_caps_toggle";
      numlock_by_default = true;
      repeat_delay = 300;
      follow_mouse = 0;
      float_switch_override_focus = 0;
      mouse_refocus = 0;
      sensitivity = 0;
      touchpad = {natural_scroll = true;};
    };

    general = {
      layout = "dwindle";
      gaps_in = 6;
      gaps_out = 12;
      border_size = 4;
      # "col.active_border" = "rgb(98971A) rgb(CC241D) 45deg";
      # "col.inactive_border" = "0x00000000";
      # border_part_of_window = false;
      no_border_on_floating = false;
    };

    misc = {
      disable_autoreload = true;
      disable_hyprland_logo = true;
      always_follow_on_dnd = true;
      layers_hog_keyboard_focus = true;
      animate_manual_resizes = false;
      enable_swallow = true;
      focus_on_activate = true;
      new_window_takes_over_fullscreen = 2;
      middle_click_paste = false;
    };

    dwindle = {
      force_split = 2;
      special_scale_factor = 1.0;
      split_width_multiplier = 1.0;
      use_active_for_splits = true;
      pseudotile = "yes";
      preserve_split = "yes";
    };

    master = {
      new_status = "master";
      special_scale_factor = 1;
    };

    decoration = {
      rounding = 3;
      # active_opacity = 0.90;
      # inactive_opacity = 0.90;
      # fullscreen_opacity = 1.0;

      blur = {
        enabled = true;
        size = 3;
        passes = 2;
        brightness = 1;
        contrast = 1.4;
        ignore_opacity = true;
        noise = 0;
        new_optimizations = true;
        xray = true;
      };

      shadow = {
        enabled = true;

        ignore_window = true;
        offset = "0 2";
        range = 20;
        render_power = 3;
        # color = "rgba(00000055)";
      };
    };

    animations = {
      enabled = true;

      bezier = [
        "fluent_decel, 0, 0.2, 0.4, 1"
        "easeOutCirc, 0, 0.55, 0.45, 1"
        "easeOutCubic, 0.33, 1, 0.68, 1"
        "fade_curve, 0, 0.55, 0.45, 1"

        "specialWorkSwitch, 0.05, 0.7, 0.1, 1"
        "emphasizedAccel, 0.3, 0, 0.8, 0.15"
        "emphasizedDecel, 0.05, 0.7, 0.1, 1"
        "standard, 0.2, 0, 0, 1"
      ];

      animation = [
        # name, enable, speed, curve, style
        "layersIn, 1, 5, emphasizedDecel, slide"
        "layersOut, 1, 4, emphasizedAccel, slide"
        "fadeLayers, 1, 5, standard"
        "windowsIn, 1, 5, emphasizedDecel"
        "windowsOut, 1, 3, emphasizedAccel"
        "windowsMove, 1, 6, standard"
        "workspaces, 1, 5, standard"
        "specialWorkspace, 1, 4, specialWorkSwitch, slidefadevert 15%"
        "fade, 1, 6, standard"
        "fadeDim, 1, 6, standard"
        "border, 1, 6, standard"

        # Windows
        "windowsIn,   0, 4, easeOutCubic,  popin 20%" # window open
        "windowsOut,  0, 4, fluent_decel,  popin 80%" # window close.
        "windowsMove, 1, 2, fluent_decel, slide" # everything in between, moving, dragging, resizing.

        # Fade
        "fadeIn,      1, 3,   fade_curve" # fade in (open) -> layers and windows
        "fadeOut,     1, 3,   fade_curve" # fade out (close) -> layers and windows
        "fadeSwitch,  0, 1,   easeOutCirc" # fade on changing activewindow and its opacity
        "fadeShadow,  1, 10,  easeOutCirc" # fade on changing activewindow for shadows
        "fadeDim,     1, 4,   fluent_decel" # the easing of the dimming of inactive windows
        "border,      1, 2.7, easeOutCirc" # for animating the border's color switch speed
        "borderangle, 1, 30,  fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
        "workspaces,  1, 4,   easeOutCubic, slidevert" # styles: slide, slidevert, fade, slidefade, slidefadevert
      ];
    };

    binds = {movefocus_cycles_fullscreen = true;};
    layerrule =
      (map (x: "animation fade, ${x}") [
        "hyprpicker"
        "logout_dialog"
        "selection"
        "wayfreeze"
        "caelestia-(drawers|background)"
      ])
      ++ (map (x: "${x} ,caelestia-.*") [
        "blur"
        "blurpopups"
        "ignorealpha 0.57"
      ])
      ++ [
        "order 1 , caelestia-border-exclusion"
        "order 2 , caelestia-bar"
        "xray 1, caelestia-(border|launcher|bar|sidebar|navbar|mediadisplay|screencorners)"
        "noanim, caelestia-(launcher|osd|notifications|border-exclusion|area-picker)"
      ];

    # mouse binding
    bindm = [
      "SUPER, mouse:272, movewindow"
      "SUPER, mouse:273, resizewindow"
    ];
    windowrulev2 = [
      ''
        float, class:^(blueberry\.py)$
      ''
      ''
        keepaspectratio, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
      ''
      ''
        move 73% 72%, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
      ''
      ''
        size 25%, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
      ''
      ''
        float, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
      ''
      ''
        pin, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
      ''
      ''
        immediate, title:.*\.exe
      ''
      "noshadow, floating:0"
    ];

    # windowrule
    windowrule = [
      "nodim, xwayland:1, title:win[0-9]+"
      "noshadow, xwayland:1, title:win[0-9]+"
      "rounding 10, xwayland:1, title:win[0-9]+"
      "float, class:guifetch"
      "float, class:yad"
      "float, class:zenity"
      "float, class:wev"
      ''float, class:org\.gnome\.FileRoller''
      "float, class:file-roller "
      "float, class:blueman-manager"
      ''float, class:com\.github\.GradienceTeam\.Gradience''
      "float, class:feh"
      "float, class:imv"
      "float, class:system-config-printer"
      "float, class:quickshell"
      "float, class:foot, title:nmtui"
      "size 60% 70%, class:foot, title:nmtui"
      "center 1, class:foot, title:nmtui"
      ''float, class:org\.gnome\.Settings''
      ''size 70% 80%, class:org\.gnome\.Settings''
      ''center 1, class:org\.gnome\.Settings''
      ''float, class:org\.pulseaudio\.pavucontrol|yad-icon-browser''
      ''size 60% 70%, class:org\.pulseaudio\.pavucontrol|yad-icon-browser''
      ''center 1, class:org\.pulseaudio\.pavucontrol|yad-icon-browser''
      "float, class:nwg-look"
      "size 50% 60%, class:nwg-look"
      "center 1, class:nwg-look"
      "float, title:(Select|Open)( a)? (File|Folder)(s)?"
      "float, title:File (Operation|Upload)( Progress)?"
      "float, title:.* Properties"
      "float, title:Export Image as PNG"
      "float, title:GIMP Crash Debug"
      "float, title:Save As"
      "float, title:Library"
      "float,class:^(dialog)$"

      "float,class:^(Viewnior)$"
      "float,class:^(imv)$"
      "float,class:^(mpv)$"
      "tile,class:^(Aseprite)$"
      "float,class:^(Audacious)$"
      "pin,class:^(rofi)$"
      "pin,class:^(waypaper)$"
      # "idleinhibit focus,mpv"
      # "float,udiskie"
      "opacity 1.0 override 1.0 override, title:^(.*imv.*)$"
      "opacity 1.0 override 1.0 override, title:^(.*mpv.*)$"
      "opacity 1.0 override 1.0 override, class:(Aseprite)"
      "idleinhibit focus, class:^(mpv)$"
      "idleinhibit fullscreen, class:^(firefox)$"
      "size 725 330,class:^(SoundWireServer)$"
      "float,class:^(org.gnome.FileRoller)$"
      "float,class:^(org.pulseaudio.pavucontrol)$"
      "float,class:^(file_progress)$"
      "float,class:^(confirm)$"
      "float,class:^(download)$"
      "float,class:^(notification)$"
      "float,class:^(error)$"
      "float,class:^(confirmreset)$"
      "float,title:^(Open File)$"
      "float,title:^(File Upload)$"
      "float,title:^(branchdialog)$"
      "float,title:^(Confirm to replace files)$"
      "float,title:^(File Operation Progress)$"
      "move 100%-w-2% 100%-w-3%, title:Picture(-| )in(-| )[Pp]icture"
      "keepaspectratio, title:Picture(-| )in(-| )[Pp]icture"
      "float, title:Picture(-| )in(-| )[Pp]icture"
      "pin, title:Picture(-| )in(-| )[Pp]icture"

      "rounding 10, title:, class:steam"
      "float, title:Friends List, class:steam"
      "immediate, class:steam_app_[0-9]+"
      "idleinhibit always, class:steam_app_[0-9]+"

      "opacity 0.0 override,class:^(xwaylandvideobridge)$"
      "noanim,class:^(xwaylandvideobridge)$"
      "noinitialfocus,class:^(xwaylandvideobridge)$"
      "maxsize 1 1,class:^(xwaylandvideobridge)$"
      "noblur,class:^(xwaylandvideobridge)$"

      # No gaps when only
      "bordersize 2, floating:0, onworkspace:w[t1]"
      "rounding 0, floating:0, onworkspace:w[t1]"
      "bordersize 2, floating:0, onworkspace:w[tg1]"
      "rounding 0, floating:0, onworkspace:w[tg1]"
      "bordersize 2, floating:0, onworkspace:f[1]"
      "rounding 0, floating:0, onworkspace:f[1]"

      # "maxsize 1111 700, floating: 1"
      # "center, floating: 1"

      # Remove context menu transparency in chromium based apps
      "opaque,class:^()$,title:^()$"
      "noshadow,class:^()$,title:^()$"
      "noblur,class:^()$,title:^()$"
    ];

    # No gaps when only
    workspace = [
      "w[t1], gapsout:2, gapsin:0"
      "w[tg1], gapsout:2, gapsin:0"
      "f[1], gapsout:2, gapsin:0"
    ];
  };
}
