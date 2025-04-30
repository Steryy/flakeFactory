{ ... }:
let

  imports = [
    ./importer.nix
    ./_packages.nix
    ({ options, lib, ... }: {
      config = lib.mkMerge [

        (lib.optionalAttrs (options ? "persistence") {
          persistence.cache.directories = [
            {
              directory = ".local/share/Steam";
              method = "symlink";
            }
            ".local/share/supermaven"
            ".local/share/anime-games-launcher"
            ".supermaven"
            ".var"
          ];
        })

      ];
    })
    ({ config, pkgs,
      # lib,
      ... }: {
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
