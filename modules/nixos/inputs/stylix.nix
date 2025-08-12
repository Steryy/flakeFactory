{
  lib,
  extraInputs,
  pkgs,
  config,
  options,
  ...
}: let
  inherit
    (lib.local.colors)
    rgb
    hex
    rgbString2Rgb
    ;
in {
  imports = [
    extraInputs.stylix.nixosModules.stylix
  ];
  config = lib.mkMerge [
    (lib.optionalAttrs (options.programs ? "matugen") {
      stylix = {
        base16Scheme = let
          polarity = config.stylix.polarity;
          colors =
            lib.mapAttrs (_: v: rgb.toHex (rgbString2Rgb v))
            config.programs.matugen.theme.colors."${polarity}";
        in (
          with colors;
            if polarity == "dark"
            then {
              base00 = background;
              base01 = surface_container;
              base02 = surface_container_highest;
              base03 = outline;
              base04 = outline_variant;
              base05 = on_surface;
              base06 = secondary_fixed;
              base07 = on_primary_container;
              base08 = error;
              base09 = tertiary;
              base0A = secondary;
              base0B = primary;
              base0C = primary_fixed;
              base0D = surface_tint;
              base0E = tertiary_fixed;
              base0F = error_container;
              # base0F = on_error_container;

              base10 = surface_container_lowest;
              base11 = scrim;
              base12 = hex.lighten error 8;
              base13 = hex.lighten secondary 9;
              base14 = hex.lighten primary 9;
              base15 = hex.lighten primary_fixed 9;
              base16 = hex.lighten surface_tint 9;
              base17 = hex.lighten tertiary_fixed 9;
            }
            else {
              base00 = background;
              base01 = surface_container;
              base02 = surface_container_highest;
              base03 = outline;
              base04 = on_surface_variant;
              base05 = on_surface;
              base06 = on_secondary_fixed;
              base07 = on_primary_container;
              base08 = error;
              base09 = on_tertiary;
              base0A = on_secondary_container;
              base0B = on_secondary_fixed_variant;
              base0C = on_primary_fixed;
              base0D = surface_tint;
              # base0D = surface_variant;
              base0E = on_tertiary_fixed;
              base0F = on_error_container;
            }
        );

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
        targets.nixos-icons.enable = false;

        targets.qt.platform = lib.mkForce "qtct";
        targets.qt.enable = true;
        targets.gtk.enable = true;
      };
    }
  ];
}
