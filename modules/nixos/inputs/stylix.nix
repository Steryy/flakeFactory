{
  lib,
  inputs,
  pkgs,
  config,
  options,
  ...
}: let
  adjustLightness = primaryScale: rgbColorString: let
    values = builtins.split "," (
      builtins.replaceStrings ["rgb(" ")"] ["" ""] rgbColorString
    );
    preLightness =
      (
        (builtins.fromJSON (builtins.elemAt values 0))
        + (builtins.fromJSON (builtins.elemAt values 2))
        + (builtins.fromJSON (builtins.elemAt values 4))
      )
      / 3.0;
    adj =
      (preLightness / 255.0 * (1.0 - primaryScale) + primaryScale)
      / preLightness
      * 255.0;
    round = x: let
      floored = lib.floor x;
      diff = x - floored;
    in
      if diff >= 0.5
      then floored + 1
      else floored;
    adjust = int:
      lib.pipe int [
        (lib.elemAt values)
        lib.fromJSON
        (x: x * adj)
        (lib.min 255.0)
        (lib.max 0.0)
        round
        lib.toHexString
        (lib.strings.fixedWidthString 2 "0")
        toString
      ];
    # lib.max (lib.min (lib.fromJSON (lib.elemAt values int) * adj) 255.0) 0.0;
  in
    (adjust 0)
    + (adjust 2)
    + (adjust 4);
in {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];
  options.stylix.primaryScale = {
    dark = lib.mkOption {
      type = lib.types.addCheck lib.types.float (x: x >= -1.0 && x <= 1.0);
      default = 0.0;
      description = ''
        Use this option to change the generated dark color scheme's contrast.
        0 represents standard (i.e. the design as spec'd),
        and 1 represents maximum contrast.
      '';
    };
    light = lib.mkOption {
      type = lib.types.addCheck lib.types.float (x: x >= -1.0 && x <= 1.0);
      default = 0.0;
      description = ''
        Use this option to change the generated light color scheme's contrast.
        0 represents standard (i.e. the design as spec'd),
        and 1 represents maximum contrast.
      '';
    };
  };
  config = lib.mkMerge [
    (lib.optionalAttrs (options.programs ? "matugen") {
      stylix = {
        base16Scheme = let
          colors = config.programs.matugen.theme.colors."${config.stylix.polarity}";
        in
          lib.mapAttrs (_: v: let
            adjust = config.stylix.primaryScale.${config.stylix.polarity};
          in
            adjustLightness adjust v)
          {
            base00 = colors.background;
            base01 = colors.surface_container;
            base02 = colors.surface_container_highest;
            base03 = colors.outline;
            base04 = colors.on_surface_variant;
            base05 = colors.on_surface;
            base06 = colors.secondary_fixed;
            base07 = colors.on_primary_container;
            base08 = colors.error;
            base09 = colors.tertiary;
            base0A = colors.secondary;
            base0B = colors.primary;
            base0C = colors.primary_fixed;
            base0D = colors.surface_tint;
            base0E = colors.tertiary_fixed;
            base0F = colors.on_error_container;
          };

        image = config.programs.matugen.wallpaper;
      };
    })
    {
      stylix = {
        enable = true;
        polarity = "dark";
        autoEnable = true;
        fonts = {
          serif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Serif";
          };

          sansSerif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Sans";
          };

          monospace = {
            package = pkgs.nerd-fonts.lilex;
            name = "Lilex Nerd Font";
          };

          emoji = {
            package = pkgs.noto-fonts-emoji;
            name = "Noto Color Emoji";
          };
        };
        cursor = {
          name = "catppuccin-mocha-mauve-cursors";
          package = pkgs.catppuccin-cursors.mochaMauve;
          size = 48;
        };

        targets.qt.platform = "qtct";
        targets.qt.enable = true;
        targets.gtk.enable = true;
      };
    }
  ];
}
