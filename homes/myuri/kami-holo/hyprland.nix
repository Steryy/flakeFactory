{
  config,
  lib,
  options,
  ...
}: let
  c = config.stylix.cursor;
in {
  xresources.properties = {
    "Xft.dpi" = 128;
  };
  xdg.configFile = {
    "uwsm/env".text = ''
      export NIXOS_OZONE_WL=1
      export GDK_BACKEND=wayland,x11
      export GTK_USE_PORTAL=1
      export QT_QPA_PLATFORM=wayland;xcb
      export QT_QPA_PLATFORMTHEME=gtk3
      export QT_AUTO_SCREEN_SCALE_FACTOR=1
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export SDL_VIDEODRIVER=wayland
      export ANKI_WAYLAND=1
      export XCURSOR_SIZE=${toString c.size}
      export XCURSOR_THEME=${c.name}
      export GDK_SCALE=1
    '';
  };
  wayland.windowManager.hyprland.settings = {
    xwayland = {
      force_zero_scaling = true;
      create_abstract_socket = true;
      # hidpi = true;
    };

    cursor = {
      # sync_gsettings_theme = true;
      # no_hardware_cursors = 2; # change to 1 if want to disable
      enable_hyprcursor = false;
      # warp_on_change_workspace = 2;
      # no_warps = true;
    };
    source = [
      "$HOME/.config/hypr/hyprland/keybinds.conf"
    ];
    env =
      [
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_QPA_PLATFORM,wayland"
      ]
      ++ lib.optionals (options ? "stylix") [
        "HYPRCURSOR_THEME, ${c.name}"
        "HYPRCURSOR_SIZE, ${toString c.size}"
        "XCURSOR_SIZE,${toString c.size}"
        "XCURSOR_THEME,${c.name}"
      ];

    # autostart
    exec-once = [
      "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment PATH"

      "swww-daemon"
      "ags"
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
      "$mainMod" = "SUPER";
      layout = "dwindle";
      gaps_in = 6;
      gaps_out = 12;
      border_size = 2;
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
      ];

      animation = [
        # name, enable, speed, curve, style

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
        # "border,      1, 2.7, easeOutCirc"  # for animating the border's color switch speed
        # "borderangle, 1, 30,  fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
        "workspaces,  1, 4,   easeOutCubic, fade" # styles: slide, slidevert, fade, slidefade, slidefadevert
      ];
    };

    binds = {movefocus_cycles_fullscreen = true;};
    layerrule = [
      "animation slide left, sideleft.*"
      "animation slide right, sideright.*"
      "blur, bar[0-9]*"
      "blur, barcorner.*"
      "blur, cheatsheet[0-9]*"
      "blur, dock[0-9]*"
      "blur, gtk-layer-shell"
      "blur, indicator.*"
      "blur, indicator.*"
      "blur, launcher"
      "blur, logout_dialog"
      "blur, notifications"
      "blur, osk[0-9]*"
      "blur, overview[0-9]*"
      "blur, session[0-9]*"
      "blur, sideleft[0-9]*"
      "blur, sideright[0-9]*"
      "ignorealpha 0.5, launcher"
      "ignorealpha 0.69, notifications"
      "ignorealpha 0.6, bar[0-9]*"
      "ignorealpha 0.6, barcorner.*"
      "ignorealpha 0.6, cheatsheet[0-9]*"
      "ignorealpha 0.6, dock[0-9]*"
      "ignorealpha 0.6, indicator.*"
      "ignorealpha 0.6, indicator.*"
      "ignorealpha 0.6, osk[0-9]*"
      "ignorealpha 0.6, overview[0-9]*"
      "ignorealpha 0.6, sideleft[0-9]*"
      "ignorealpha 0.6, sideright[0-9]*"
      "ignorezero, gtk-layer-shell"
      "noanim, anyrun"
      "noanim, hyprpicker"
      "noanim, indicator.*"
      "noanim, noanim"
      "noanim, osk"
      "noanim, overview"
      "noanim, selection"
      "noanim, walker"
      "xray 1, .*"
    ];

    # mouse binding
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];
    windowrulev2 = [
      "noblur, xwayland:1"
      ''
        float, class:^(blueberry\.py)$
      ''
      "float, class:^(steam)$"
      "float, class:^(guifetch)$"
      "float, class:^(pavucontrol)$"
      "size 45%, class:^(pavucontrol)$"
      "center, class:^(pavucontrol)$"
      "float, class:^(org.pulseaudio.pavucontrol)$"
      "size 45%, class:^(org.pulseaudio.pavucontrol)$"
      "center, class:^(org.pulseaudio.pavucontrol)$"
      "float, class:^(nm-connection-editor)$"
      "size 45%, class:^(nm-connection-editor)$"
      "center, class:^(nm-connection-editor)$"
      ''
        tile, class:^dev\.warp\.Warp$
      ''
      ''
        float, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
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
      "center, title:^(Open File)(.*)$"
      "center, title:^(Select a File)(.*)$"
      "center, title:^(Choose wallpaper)(.*)$"
      "center, title:^(Open Folder)(.*)$"
      "center, title:^(Save As)(.*)$"
      "center, title:^(Library)(.*)$"
      "center, title:^(File Upload)(.*)$"
      "float, title:^(Open File)(.*)$"
      "float, title:^(Select a File)(.*)$"
      "float, title:^(Choose wallpaper)(.*)$"
      "float, title:^(Open Folder)(.*)$"
      "float, title:^(Save As)(.*)$"
      "float, title:^(Library)(.*)$"
      "float, title:^(File Upload)(.*)$"
      ''
        immediate, title:.*\.exe
      ''
      "immediate, class:^(steam_app)"
      "noshadow, floating:0"
    ];

    # windowrule
    windowrule = [
      "float,class:^(Viewnior)$"
      "float,class:^(imv)$"
      "float,class:^(mpv)$"
      "tile,class:^(Aseprite)$"
      "float,class:^(Audacious)$"
      "pin,class:^(rofi)$"
      "pin,class:^(waypaper)$"
      # "idleinhibit focus,mpv"
      # "float,udiskie"
      "float,title:^(Transmission)$"
      "float,title:^(Volume Control)$"
      "float,title:^(Firefox — Sharing Indicator)$"
      "move 0 0,title:^(Firefox — Sharing Indicator)$"
      "size 700 450,title:^(Volume Control)$"
      "move 40 55%,title:^(Volume Control)$"

      "float, title:^(Picture-in-Picture)$"
      "opacity 1.0 override 1.0 override, title:^(Picture-in-Picture)$"
      "pin, title:^(Picture-in-Picture)$"
      "opacity 1.0 override 1.0 override, title:^(.*imv.*)$"
      "opacity 1.0 override 1.0 override, title:^(.*mpv.*)$"
      "opacity 1.0 override 1.0 override, class:(Aseprite)"
      "opacity 1.0 override 1.0 override, class:(Unity)"
      "opacity 1.0 override 1.0 override, class:(zen)"
      "opacity 1.0 override 1.0 override, class:(evince)"
      "workspace 1, class:^(zen)$"
      "workspace 3, class:^(evince)$"
      "workspace 4, class:^(Gimp-2.10)$"
      "workspace 4, class:^(Aseprite)$"
      "workspace 5, class:^(Audacious)$"
      "workspace 5, class:^(Spotify)$"
      "workspace 8, class:^(com.obsproject.Studio)$"
      "workspace 10, class:^(discord)$"
      "workspace 10, class:^(WebCord)$"
      "idleinhibit focus, class:^(mpv)$"
      "idleinhibit fullscreen, class:^(firefox)$"
      "float,class:^(org.gnome.Calculator)$"
      "float,class:^(waypaper)$"
      "float,class:^(zenity)$"
      "size 850 500,class:^(zenity)$"
      "size 725 330,class:^(SoundWireServer)$"
      "float,class:^(org.gnome.FileRoller)$"
      "float,class:^(org.pulseaudio.pavucontrol)$"
      "float,class:^(SoundWireServer)$"
      "float,class:^(.sameboy-wrapped)$"
      "float,class:^(file_progress)$"
      "float,class:^(confirm)$"
      "float,class:^(dialog)$"
      "float,class:^(download)$"
      "float,class:^(notification)$"
      "float,class:^(error)$"
      "float,class:^(confirmreset)$"
      "float,title:^(Open File)$"
      "float,title:^(File Upload)$"
      "float,title:^(branchdialog)$"
      "float,title:^(Confirm to replace files)$"
      "float,title:^(File Operation Progress)$"

      "opacity 0.0 override,class:^(xwaylandvideobridge)$"
      "noanim,class:^(xwaylandvideobridge)$"
      "noinitialfocus,class:^(xwaylandvideobridge)$"
      "maxsize 1 1,class:^(xwaylandvideobridge)$"
      "noblur,class:^(xwaylandvideobridge)$"

      # No gaps when only
      "bordersize 0, floating:0, onworkspace:w[t1]"
      "rounding 0, floating:0, onworkspace:w[t1]"
      "bordersize 0, floating:0, onworkspace:w[tg1]"
      "rounding 0, floating:0, onworkspace:w[tg1]"
      "bordersize 0, floating:0, onworkspace:f[1]"
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
      "w[t1], gapsout:0, gapsin:0"
      "w[tg1], gapsout:0, gapsin:0"
      "f[1], gapsout:0, gapsin:0"
    ];
  };

  file.".config/hypr/hyprland/keybinds.conf".text = ''
    # Lines ending with `# [hidden]` won't be shown on cheatsheet
    # Lines starting with #! are section headings

    bindl = Alt ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle # [hidden]
    bindl = Super ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle # [hidden]
    bindl = ,XF86AudioMute, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0% # [hidden]
    bindl = Super+Shift,M, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0% # [hidden]
    bindle=, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ # [hidden]
    bindle=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- # [hidden]

    # Uncomment these if you can't get AGS to work
    #bindle=, XF86MonBrightnessUp, exec, brightnessctl set '12.75+'
    #bindle=, XF86MonBrightnessDown, exec, brightnessctl set '12.75-'

    #!
    ##! Essentials for beginners

    bind = Super, T, exec, ghostty # Launch foot (terminal)
    bind = Super, Return, exec, ghostty # Launch foot (terminal)
    bind = , Super, exec, true # Open app launcher
    bind = Ctrl+Super, T, exec, ~/.config/ags/scripts/color_generation/switchwall.sh # Change wallpaper
    ##! Actions
    # Screenshot, Record, OCR, Color picker, Clipboard history
    bind = Super, V, exec, pkill fuzzel || cliphist list | fuzzel  --match-mode fzf --dmenu | cliphist decode | wl-copy # Clipboard history >> clipboard
    bind = Super, Period, exec, pkill fuzzel || ~/.local/bin/fuzzel-emoji # Pick emoji >> clipboard
    bind = Ctrl+Shift+Alt, Delete, exec, pkill wlogout || wlogout -p layer-shell # [hidden]
    bind = Super+Shift, S, exec, ~/.config/ags/scripts/grimblast.sh --freeze copy area # Screen snip
    bind = Super+Shift+Alt, S, exec, grim -g "$(slurp)" - | swappy -f - # Screen snip >> edit
    # OCR
    bind = Super+Shift,T,exec,grim -g "$(slurp $SLURP_ARGS)" "tmp.png" && tesseract -l eng "tmp.png" - | wl-copy && rm "tmp.png" # Screen snip to text >> clipboard
    bind = Ctrl+Super+Shift,S,exec,grim -g "$(slurp $SLURP_ARGS)" "tmp.png" && tesseract "tmp.png" - | wl-copy && rm "tmp.png" # [hidden]
    # Color picker
    bind = Super+Shift, C, exec, hyprpicker -a # Pick color (Hex) >> clipboard
    # Fullscreen screenshot
    bindl=,Print,exec,grim - | wl-copy # Screenshot >> clipboard
    bindl= Ctrl,Print, exec, mkdir -p ~/Pictures/Screenshots && ~/.config/ags/scripts/grimblast.sh copysave screen ~/Pictures/Screenshots/Screenshot_"$(date '+%Y-%m-%d_%H.%M.%S')".png # Screenshot >> clipboard & file
    # AI
    bind = Super+Shift+Alt, mouse:273, exec, ~/.config/ags/scripts/ai/primary-buffer-query.sh # Provide AI response for selected text

    # Recording stuff
    bind = Super+Alt, R, exec, ~/.config/ags/scripts/record-script.sh # Record region (no sound)
    bind = Ctrl+Alt, R, exec, ~/.config/ags/scripts/record-script.sh --fullscreen # [hidden] Record screen (no sound)
    bind = Super+Shift+Alt, R, exec, ~/.config/ags/scripts/record-script.sh --fullscreen-sound # Record screen (with sound)
    ##! Session
    bind = Ctrl+Super, L, exec, ags run-js 'lock.lock()' # [hidden]
    bind = Super, L, exec, loginctl lock-session # Lock
    bind = Super+Shift, L, exec, loginctl lock-session # [hidden]
    bindl = Super+Shift, L, exec, sleep 0.1 && systemctl suspend || loginctl suspend # Suspend system
    bind = Ctrl+Shift+Alt+Super, Delete, exec, systemctl poweroff || loginctl poweroff # [hidden] Power off

    #!
    ##! Window management
    # Focusing
    #/# bind = Super, ←/↑/→/↓,, # Move focus in direction
    bind = Super, Left, movefocus, l # [hidden]
    bind = Super, Right, movefocus, r # [hidden]
    bind = Super, Up, movefocus, u # [hidden]
    bind = Super, Down, movefocus, d # [hidden]
    bind = Super, BracketLeft, movefocus, l # [hidden]
    bind = Super, BracketRight, movefocus, r # [hidden]
    bindm = Super, mouse:272, movewindow
    bindm = Super, mouse:273, resizewindow
    bind = Super, Q, killactive,
    bind = Super+Shift+Alt, Q, exec, hyprctl kill # Pick and kill a window
    ##! Window arrangement
    #/# bind = Super+Shift, ←/↑/→/↓,, # Window: move in direction
    bind = Super+Shift, Left, movewindow, l # [hidden]
    bind = Super+Shift, Right, movewindow, r # [hidden]
    bind = Super+Shift, Up, movewindow, u # [hidden]
    bind = Super+Shift, Down, movewindow, d # [hidden]
    # Window split ratio
    #/# binde = Super, +/-,, # Window: split ratio +/- 0.1
    binde = Super, Minus, splitratio, -0.1 # [hidden]
    binde = Super, Equal, splitratio, +0.1 # [hidden]
    binde = Super, Semicolon, splitratio, -0.1 # [hidden]
    binde = Super, Apostrophe, splitratio, +0.1 # [hidden]
    # Positioning mode
    bind = Super+Alt, Space, togglefloating,
    bind = Super+Alt, F, fullscreenstate, 0 3 # Toggle fake fullscreen
    bind = Super, F, fullscreen, 0
    bind = Super, D, fullscreen, 1

    #!
    ##! Workspace navigation
    # Switching
    #/# bind = Super, Hash,, # Focus workspace # (1, 2, 3, 4, ...)
    bind = Super, 1, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh workspace 1 # [hidden]
    bind = Super, 2, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh workspace 2 # [hidden]
    bind = Super, 3, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh workspace 3 # [hidden]
    bind = Super, 4, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh workspace 4 # [hidden]
    bind = Super, 5, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh workspace 5 # [hidden]
    bind = Super, 6, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh workspace 6 # [hidden]
    bind = Super, 7, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh workspace 7 # [hidden]
    bind = Super, 8, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh workspace 8 # [hidden]
    bind = Super, 9, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh workspace 9 # [hidden]
    bind = Super, 0, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh workspace 10 # [hidden]

    #/# bind = Super, Scroll ↑/↓,, # Workspace: focus left/right
    bind = Super, mouse_up, workspace, +1 # [hidden]
    bind = Super, mouse_down, workspace, -1 # [hidden]
    bind = Ctrl+Super, mouse_up, workspace, r+1 # [hidden]
    bind = Ctrl+Super, mouse_down, workspace, r-1 # [hidden]
    #/# bind = Ctrl+Super, ←/→,, # Workspace: focus left/right
    bind = Ctrl+Super, Right, workspace, r+1 # [hidden]
    bind = Ctrl+Super, Left, workspace, r-1 # [hidden]
    #/# bind = Ctrl+Super+Alt, ←/→,, # Workspace: focus non-empty left/right
    bind = Ctrl+Super+Alt, Right, workspace, m+1 # [hidden]
    bind = Ctrl+Super+Alt, Left, workspace, m-1 # [hidden]
    #/# bind = Super, Page_↑/↓,, # Workspace: focus left/right
    bind = Super, Page_Down, workspace, +1 # [hidden]
    bind = Super, Page_Up, workspace, -1 # [hidden]
    bind = Ctrl+Super, Page_Down, workspace, r+1 # [hidden]
    bind = Ctrl+Super, Page_Up, workspace, r-1 # [hidden]
    ## Special
    bind = Super, S, togglespecialworkspace,
    bind = Super, mouse:275, togglespecialworkspace,

    ##! Workspace management
    # Move window to workspace Super + Alt + [0-9]
    #/# bind = Super+Alt, Hash,, # Window: move to workspace # (1, 2, 3, 4, ...)
    bind = Super+Alt, 1, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 1 # [hidden]
    bind = Super+Alt, 2, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 2 # [hidden]
    bind = Super+Alt, 3, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 3 # [hidden]
    bind = Super+Alt, 4, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 4 # [hidden]
    bind = Super+Alt, 5, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 5 # [hidden]
    bind = Super+Alt, 6, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 6 # [hidden]
    bind = Super+Alt, 7, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 7 # [hidden]
    bind = Super+Alt, 8, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 8 # [hidden]
    bind = Super+Alt, 9, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 9 # [hidden]
    bind = Super+Alt, 0, exec, ~/.config/ags/scripts/hyprland/workspace_action.sh movetoworkspacesilent 10 # [hidden]

    bind = Ctrl+Super+Shift, Up, movetoworkspacesilent, special # [hidden]

    bind = Ctrl+Super+Shift, Right, movetoworkspace, r+1 # [hidden]
    bind = Ctrl+Super+Shift, Left, movetoworkspace, r-1 # [hidden]
    bind = Ctrl+Super, BracketLeft, workspace, -1 # [hidden]
    bind = Ctrl+Super, BracketRight, workspace, +1 # [hidden]
    bind = Ctrl+Super, Up, workspace, r-5 # [hidden]
    bind = Ctrl+Super, Down, workspace, r+5 # [hidden]
    #/# bind = Super+Shift, Scroll ↑/↓,, # Window: move to workspace left/right
    bind = Super+Shift, mouse_down, movetoworkspace, r-1 # [hidden]
    bind = Super+Shift, mouse_up, movetoworkspace, r+1 # [hidden]
    bind = Super+Alt, mouse_down, movetoworkspace, -1 # [hidden]
    bind = Super+Alt, mouse_up, movetoworkspace, +1 # [hidden]
    #/# bind = Super+Shift, Page_↑/↓,, # Window: move to workspace left/right
    bind = Super+Alt, Page_Down, movetoworkspace, +1 # [hidden]
    bind = Super+Alt, Page_Up, movetoworkspace, -1 # [hidden]
    bind = Super+Shift, Page_Down, movetoworkspace, r+1  # [hidden]
    bind = Super+Shift, Page_Up, movetoworkspace, r-1  # [hidden]
    bind = Super+Alt, S, movetoworkspacesilent, special
    bind = Super, P, pin

    bind = Ctrl+Super, S, togglespecialworkspace, # [hidden]
    bind = Alt, Tab, cyclenext # [hidden] sus keybind
    bind = Alt, Tab, bringactivetotop, # [hidden] bring it to the top

    #!
    ##! Widgets
    bindr = Ctrl+Super, R, exec, killall ags ags ydotool; ags & # Restart widgets
    bindr = Ctrl+Super+Alt, R, exec, hyprctl reload; killall ags ydotool; ags & # [hidden]
    bind = Ctrl+Alt, Slash, exec, ags run-js 'cycleMode();' # Cycle bar mode (normal, focus)
    bindir = Super, Super_L, exec, ags -t 'overview' # Toggle overview/launcher
    bind = Super, Tab, exec, ags -t 'overview' # [hidden]
    bind = Super, Slash, exec, for ((i=0; i<$(hyprctl monitors -j | jq length); i++)); do ags -t "cheatsheet""$i"; done # Show cheatsheet
    bind = Super, B, exec, ags -t 'sideleft' # Toggle left sidebar
    bind = Super, A, exec, ags -t 'sideleft' # [hidden]
    bind = Super, O, exec, ags -t 'sideleft' # [hidden]
    bind = Super, N, exec, ags -t 'sideright' # Toggle right sidebar
    bind = Super, M, exec, ags run-js 'openMusicControls.value = (!mpris.getPlayer() ? false : !openMusicControls.value);' # Toggle music controls
    bind = Super, Comma, exec, ags run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);' # View color scheme and options
    bind = Super, K, exec, for ((i=0; i<$(hyprctl monitors -j | jq length); i++)); do ags -t "osk""$i"; done # Toggle on-screen keyboard
    bind = Ctrl+Alt, Delete, exec, for ((i=0; i<$(hyprctl monitors -j | jq length); i++)); do ags -t "session""$i"; done # Toggle power menu
    bind = Ctrl+Super, G, exec, for ((i=0; i<$(hyprctl monitors -j | jq length); i++)); do ags -t "crosshair""$i"; done # Toggle crosshair
    bindle=, XF86MonBrightnessUp, exec, ags run-js 'brightness.screen_value += 0.05; indicator.popup(1);' # [hidden]
    bindle=, XF86MonBrightnessDown, exec, ags run-js 'brightness.screen_value -= 0.05; indicator.popup(1);' # [hidden]
    bindl  = , XF86AudioMute, exec, ags run-js 'indicator.popup(1);' # [hidden]
    bindl  = Super+Shift,M,   exec, ags run-js 'indicator.popup(1);' # [hidden]

    # Testing
    # bind = SuperAlt, f12, exec, notify-send "Hyprland version: $(hyprctl version | head -2 | tail -1 | cut -f2 -d ' ')" "owo" -a 'Hyprland keybind'
    # bind = Super+Alt, f12, exec, notify-send "Millis since epoch" "$(date +%s%N | cut -b1-13)" -a 'Hyprland keybind'
    bind = Super+Alt, f12, exec, notify-send 'Test notification' "Here's a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!" -a 'Shell' -A "Test1=I got it!" -A "Test2=Another action" -t 5000 # [hidden]
    bind = Super+Alt, Equal, exec, notify-send "Urgent notification" "Ah hell no" -u critical -a 'Hyprland keybind' # [hidden]

    ##! Media
    bindl= Super+Shift, N, exec, playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"` # Next track
    bindl= ,XF86AudioNext, exec, playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"` # [hidden]
    bindl= ,XF86AudioPrev, exec, playerctl previous # [hidden]
    bindel = Super+Shift, Comma, exec, ~/.config/ags/scripts/music/adjust-volume.sh -0.03 # Raise music volume
    bindel = Super+Shift, Period, exec, ~/.config/ags/scripts/music/adjust-volume.sh 0.03 # Lower music volume
    bind = Super+Shift+Alt, mouse:275, exec, playerctl previous # [hidden]
    bind = Super+Shift+Alt, mouse:276, exec, playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"` # [hidden]
    bindl= Super+Shift, B, exec, playerctl previous # Previous track
    bindl= Super+Shift, P, exec, playerctl play-pause # Play/pause media
    bindl= ,XF86AudioPlay, exec, playerctl play-pause # [hidden]
    bindl= ,XF86AudioPause, exec, playerctl play-pause # [hidden]

    #!
    ##! Apps
    bind = Super+Alt, E, exec, thunar # [hidden]
    bind = Super, W, exec, google-chrome-stable || firefox # [hidden] Let's not give people (more) reason to shit on my rice
    bind = Ctrl+Super, W, exec, firefox # Launch Firefox (browser)
    bind = Super, X, exec, gnome-text-editor --new-window # Launch GNOME Text Editor
    bind = Super+Shift, W, exec, wps # Launch WPS Office
    bind = Super, I, exec, XDG_CURRENT_DESKTOP="gnome" gnome-control-center # Launch GNOME Settings
    bind = Ctrl+Super, V, exec, pavucontrol # Launch pavucontrol (volume mixer)
    bind = Ctrl+Super+Shift, V, exec, easyeffects # Launch EasyEffects (equalizer & other audio effects)
    bind = Ctrl+Shift, Escape, exec, gnome-system-monitor # Launch GNOME System monitor
    bind = Ctrl+Super, Slash, exec, pkill anyrun || anyrun # Toggle fallback launcher: anyrun
    bind = Super+Alt, Slash, exec, pkill fuzzel || fuzzel # Toggle fallback launcher: fuzzel

    # Cursed stuff
    ## Make window not amogus large
    bind = Ctrl+Super, Backslash, resizeactive, exact 640 480 # [hidden]
  '';
}
