{ config, inputs, pkgs, lib, options, ... }: {
  imports = [ inputs.matugen.nixosModules.matugen ];
  config = lib.mkMerge [
    {

      programs.matugen = {
        enable = true;
        jsonFormat = "rgb";
        contrast = 0.2;
        package = with pkgs; matugen;
        wallpaper = pkgs.fetchurl {
          url = "https://cdn.wallpapersafari.com/2/33/6yPHfo.jpg";
          sha256 = "0f156pryqxkncq92bgf3xm4ilcx5na12ybmc4vg9f6rfs2sfz5ql";
        };
      };
    }

    (lib.optionalAttrs (options.programs ? "stylix") {
      programs.matugen.variant =
        if config.stylix.polarity == "dark" then "amoled" else "light";
    })

  ];

}
