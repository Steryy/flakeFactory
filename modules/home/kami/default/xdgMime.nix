{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit
    (config.xdg.mime)
    editors
    browsers
    mediaPlayers
    fileManagers
    documentViewers
    imageViewers
    ;

  associations = {
    "text/html" = browsers;
    "x-scheme-handler/http" = browsers;
    "x-scheme-handler/https" = browsers;
    "x-scheme-handler/ftp" = browsers;
    "x-scheme-handler/about" = browsers;
    "x-scheme-handler/unknown" = browsers;
    "application/x-extension-htm" = browsers;
    "application/x-extension-html" = browsers;
    "application/x-extension-shtml" = browsers;
    "application/xhtml+xml" = browsers;
    "application/x-extension-xhtml" = browsers;
    "application/x-extension-xht" = browsers;

    "inode/directory" = fileManagers;

    "application/json" = editors;
    "application/pdf" = documentViewers;
    "x-scheme-handler/spotify" = ["spotify.desktop"];
    "x-scheme-handler/discord" = ["vesktop.desktop" "discord.desktop"];
    "x-scheme-handler/tg" = ["telegram.desktop"];
  };
  globAssociations = {
    "audio/*" = mediaPlayers;
    "video/*" = mediaPlayers;
    "image/*" = imageViewers;
    "text/*" = editors;
  };
in {
  options.xdg.mime = {
    browsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };

    documentViewers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };

    imageViewers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };

    fileManagers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    mediaPlayers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    editors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };
  config = {
    xdg = {
      mimeApps = {
        enable = true;

        defaultApplications =
          globAssociations
          // associations;
      };
    };

    home = {
      file = {
        ".profile".text = ''
          . "${config.xdg.stateHome}/nix/profile/etc/profile.d/hm-session-vars.sh"
        '';
      };
    };
    # xdg.configFile."mimeo/associations.txt".text = ''
    #   ${video-wrapper}/bin/video-wrapper %U
    #     ^https?://(www.|vm.)?(youtu|odysee|instagram|tiktok)(be)?.(com|be)/.*
    # '';
  };
}
