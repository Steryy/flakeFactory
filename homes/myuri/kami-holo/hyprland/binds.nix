{
  lib,
  options,
  config,
  ...
}: let
  multiple = x: (
    lib.imap0 (i: x (toString i)) (
      ["10"] ++ (lib.genList (x: toString (x + 1)) 9)
    )
  );
in {
  wayland.windowManager.hyprland.settings = {
    bindle = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86MonBrightnessUp, exec, brightnessctl set '12.75+'"
      ", XF86MonBrightnessDown, exec, brightnessctl set '12.75-'"
    ];
    bindl = [
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"

      ",XF86AudioPrev, exec, playerctl previous"
      ",XF86AudioPlay, exec, playerctl play-pause"
      ",XF86AudioPause, exec, playerctl play-pause"

      '',XF86AudioNext, exec, playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`''
    ];
    bindir =
      lib.optional (options.programs ? "caelestia" && config.programs.caelestia.enable)
      "Super, Super_L, exec, caelestia-shell ipc call drawers toggle launcher";
    bind =
      (lib.optional (options.programs ? "caelestia" && config.programs.caelestia.enable)
        ", Super, exec, true")
      ++ [
        "Super, Return, exec, ghostty " # Launch foot (terminal)
        "Super, T, exec, pypr toggle term " # Launch foot (terminal)
        "Super, b, exec, pypr toggle fileman " # Launch foot (terminal)
        "Super, h, exec, pypr layout_center prev " # [hidden]
        "Super, l, exec, pypr layout_center next " # [hidden]
        "Super, k, exec, pypr layout_center prev2 " # [hidden]
        "Super, j, exec, pypr layout_center next2 " # [hidden]

        "Super, Q, killactive,"
        "Super+Shift+Alt, Q, exec, hyprctl kill "

        "Super, Minus, splitratio, -0.1"
        "Super, Equal, splitratio, +0.1"
        "Super, Semicolon, splitratio, -0.1"
        "Super, Apostrophe, splitratio, +0.1"
        "Super+Alt, Space, togglefloating,"
        "Super, F, fullscreen, 0"
        "Super, D, fullscreen, 1"
        "SUPER, M, exec, pypr layout_center toggle"

        "Super, mouse_up, workspace, +1"
        "Super, mouse_down, workspace, -1"
        "Ctrl+Super, mouse_up, workspace, r+1"
        "Ctrl+Super, mouse_down, workspace, r-1"
        "Ctrl+Super, l, workspace, r+1"
        "Ctrl+Super, h, workspace, r-1"
        "Super, S, togglespecialworkspace,"
        "Super, mouse:275, togglespecialworkspace,"

        "Ctrl+Super+Shift, Up, movetoworkspacesilent, special"
        "Ctrl+Super+Shift, Right, movetoworkspace, r+1"
        "Ctrl+Super+Shift, Left, movetoworkspace, r-1"
        "Ctrl+Super, BracketLeft, workspace, -1"
        "Ctrl+Super, BracketRight, workspace, +1"
        "Ctrl+Super, Up, workspace, r-5"
        "Ctrl+Super, Down, workspace, r+5"
        "Super+Shift, mouse_down, movetoworkspace, r-1"
        "Super+Shift, mouse_up, movetoworkspace, r+1"
        "Super+Alt, mouse_down, movetoworkspace, -1"
        "Super+Alt, mouse_up, movetoworkspace, +1"
        "Super+Alt, Page_Down, movetoworkspace, +1"
        "Super+Alt, Page_Up, movetoworkspace, -1"
        "Super+Alt, S, movetoworkspacesilent, special"
        "Super, P, pin"
        "Ctrl+Super, S, togglespecialworkspace,"
        "Alt, Tab, cyclenext"
        "Alt, Tab, bringactivetotop,"
      ]
      ++ (multiple (i: x: "Super, ${i}, split:workspace, ${x} # [hidden]"));
  };
}
