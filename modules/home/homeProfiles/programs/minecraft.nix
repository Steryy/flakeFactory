{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge [
    (
      lib.optionalAttrs (options ? "persistence")
      {
        persistence.state.directories = [
          ".local/share/PrismLauncher"
          ".local/share/ATLauncher"
        ];
      }
    )
    {
      home.packages = with pkgs; [
        (prismlauncher.override {
          jdks = [temurin-bin-21 temurin-bin-8 temurin-bin-17];
        })
        (atlauncher.override {
          jre = temurin-jre-bin-21;
        })
      ];
    }
  ];
  # impermanance = [".local/share/PrismLauncher" ".local/share/ATLauncher"];
}
