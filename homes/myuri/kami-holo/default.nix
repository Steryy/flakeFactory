{
  imports = [
    ./importer.nix
    ./_packages.nix
    ./hyprland.nix
    ({ options, lib, ... }: {
      config = lib.mkMerge [

        (lib.optionalAttrs (options ? "persistence") {
          persistence.cache.directories = [
            {
              directory = ".local/share/Steam";
              method = "symlink";
            }
            ".local/share/supermaven"
            ".local/share/nvim"
            ".local/state/nvim"
            ".supermaven"
            ".var"
          ];
        })

      ];
    })
    ({  pkgs, ... }: {
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
