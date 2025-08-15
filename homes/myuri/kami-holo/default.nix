{
  imports = [
    ./_packages.nix
    ./hyprland
    ({
      options,
      lib,
      ...
    }: {
      config = lib.mkMerge [
        (lib.optionalAttrs (options ? "persistence") {
          persistence.cache.files = [
            ".face"
          ];

          persistence.cache.directories = [
            {
              directory = ".local/share/Steam";
              method = "symlink";
            }
            ".local/share/nvim"
            ".local/state/nvim"
            ".local/state/wireplumber"
            ".config/vesktop"
            ".config/sops"
          ];
        })
      ];
    })
    ({
      pkgs,
      config,
      ...
    }: {
      stylix.opacity.terminal = 0.9;
      home.sessionVariables = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Zrzuty_ekranu";
        XDG_WALLPAPERS_DIR = "${config.xdg.userDirs.pictures}/Tapety";
      };

      # home.
      xdg.userDirs = let
        h = "${config.home.homeDirectory}";
        m = "${config.home.homeDirectory}/Media";
      in {
        music = "${m}/Muzyka";
        videos = "${m}/Wideo";
        documents = "${m}/Dokumenty";
        pictures = "${m}/Obrazy";
        desktop = "${h}/Pulpit";
        download = "${h}/Pobrane";
        extraConfig = {
          PROJECTS = "${h}/projects";
          XDG_SUPERMAVEN_DIR = "${h}/.supermaven";
          XDG_SUPERMAVEN_CACHE_DIR = "${h}/.local/share/supermaven";
        };
      };
      services.poweralertd.enable = true;
      home.packages = with pkgs; [
        neovim
        noto-fonts
        notonoto
        noto-fonts-emoji-blob-bin
      ];
      fonts.fontconfig.enable = true;
    })
  ];
}
