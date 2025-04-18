{ config, lib, options, ... }: {
  config = lib.mkMerge [
    (lib.optionalAttrs (options ? "persistence") {
      persistence.state.directories =
        map (x: lib.removePrefix "${config.home.homeDirectory}/" x)
        (lib.attrValues {
          inherit (config.xdg.userDirs) music videos pictures desktop documents;
          inherit (config.xdg.userDirs.extraConfig)
            XDG_SCREENSHOTS_DIR XDG_WALLPAPERS_DIR PROJECTS;

          inherit (config.programs.gpg) homedir;

          # inherit (config.xdg.userDirs)
          #   music videos documents pictures desktop download;
        });
    })
    {
      xdg = {
        enable = true;

        cacheHome = "${config.home.homeDirectory}/.cache";
        configHome = "${config.home.homeDirectory}/.config";
        dataHome = "${config.home.homeDirectory}/.local/share";
        stateHome = "${config.home.homeDirectory}/.local/state";

        userDirs = let
          h = "${config.home.homeDirectory}";
          m = "${h}/Media";
        in {
          enable = true;
          createDirectories = true;

          music = "${m}/Muzyka";
          videos = "${m}/Wideo";
          documents = "${m}/Dokumenty";
          pictures = "${m}/Obrazy";
          desktop = "${h}/Pulpit";
          download = "${h}/Pobrane";
          publicShare = null;
          templates = null;
          extraConfig = {
            OLLAMA_MODELS = "${config.xdg.stateHome}/ollama";
            WINEPREFIX = "${config.xdg.dataHome}/wine";
            PROJECTS = "${config.home.homeDirectory}/projects";
            RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
            # GPGHOME = config.programs.gpg.homedir;
            XDG_SCREENSHOTS_DIR =
              "${config.xdg.userDirs.pictures}/Zrzuty_ekranu";
            XDG_WALLPAPERS_DIR = "${config.xdg.userDirs.pictures}/Tapety";
          };
        };
      };
    }

  ];
}
