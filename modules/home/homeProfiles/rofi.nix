{
  pkgs,
  config,
  ...
}: {
  programs.rofi = {
    enable = true;
    cycle = true;
    package = pkgs.rofi-wayland;
    extraConfig = {
      # modi = "drun,calc,window,emoji,run";
      sidebar-mode = true;
      terminal = "footclient";
      show-icons = true;
      kb-remove-char-back = "BackSpace";
      kb-accept-entry = "Control+m,Return,KP_Enter";
      kb-mode-next = "Control+l";
      kb-mode-previous = "Control+h";
      kb-row-up = "Control+k,Up";
      kb-row-down = "Control+j,Down";
      kb-row-left = "Control+u";
      kb-row-right = "Control+d";
      kb-delete-entry = "Control+semicolon";
      kb-remove-char-forward = "";
      kb-remove-to-sol = "";
      kb-remove-to-eol = "";
      kb-mode-complete = "";
      display-drun = "";
      display-run = "";
      # display-emoji = "󰞅";
      # display-calc = "󰃬";
      display-window = "";
      display-filebrowser = "";
      drun-display-format = "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
      window-format = "{w} · {c} · {t}";
    };
  };
  xdg.dataFile."rofi/themes/password.rasi".text = ''

    @theme "custom"
    listview {
      lines: 11;
    }

  '';
  xdg.dataFile."rofi/themes/preview.rasi".text = ''
    @theme "custom"
    icon-current-entry {
      enabled: true;
      size: 30%;
      dynamic: true;
      padding: 5px;
      background-color: inherit;
    }
    listview-split {
      background-color: transparent;
      border-radius: 0px;
      cycle: true;
      dynamic : true;
      orientation: horizontal;
      border: 0px solid;
      children: [listview,icon-current-entry];
    }
    listview {
      lines: 11;
    }
    mainbox {
      children: [inputbar,listview-split];
    }
    element-icon {
    size:0px;
    };
  '';
}
