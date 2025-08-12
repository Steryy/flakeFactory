{
  config,
  lib,
  options,
  osConfig,
  ...
}: let
  c = config.stylix;

  env =
    [
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_TYPE,wayland"
      "XDG_SESSION_DESKTOP,Hyprland"
      "QT_QPA_PLATFORM,wayland"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
    ]
    ++ lib.optionals (options ? "stylix") [
      "HYPRCURSOR_THEME,${c.cursor.name}"
      "HYPRCURSOR_SIZE,${toString c.cursor. size}"
      "XCURSOR_SIZE,${toString c.cursor.size}"
      "XCURSOR_THEME,${c.cursor.name}"
      "QT_QPA_PLATFORMTHEME,${c.targets.qt.platform}"
    ];
  inherit (lib.local.colors) rgb hex rgbString2Rgb;
in {
  config = lib.mkMerge [
    {
      wayland.windowManager.hyprland.settings.env = env;
      xdg.configFile = {
        "uwsm/env".text = lib.concatStringsSep "\n" (lib.forEach env (x: "export ${
          lib.replaceStrings [","] ["="] x
        }"));
      };
    }
    (
      lib.optionalAttrs (
        true
        # options.services ? "caelestia-shell"
        # options.service ? "caelestia-shell"
        # &&
        # options ? "stylix"
        # && options.programs ? "matugen"
      ) {
        home.file.".local/share/caelestia/schemes/stylix/default/dark.txt".text = let
          dark =
            lib.mapAttrs' (n: v: {
              name = lib.toCamelCase n;
              value = rgb.toHex (rgbString2Rgb v);
            })
            osConfig.programs.matugen.theme.colors.dark;
          term = config.lib.stylix.colors;
          mix = hex.mix;
        in ''
          rosewater f5e0dc
          flamingo f2cdcd
          pink f5c2e7
          mauve cba6f7
          red f38ba8
          maroon eba0ac
          peach fab387
          yellow f9e2af
          green a6e3a1
          teal 94e2d5
          sky 89dceb
          sapphire 74c7ec
          blue 89b4fa
          lavender b4befe
          ${lib.strings.concatStringsSep "\n" (
            lib.mapAttrsToList (n: v: "${n} ${v}")
            (dark
              // {
                term0 = term.base00;
                term1 = term.base01;
                term2 = term.base02;
                term3 = term.base03;
                term4 = term.base04;
                term5 = term.base05;
                term6 = term.base06;
                term7 = term.base07;
                term8 = term.base08;
                term9 = term.base09;
                term10 = term.base0A;
                term11 = term.base0B;
                term12 = term.base0C;
                term13 = term.base0D;
                term14 = term.base0E;
                term15 = term.base0F;
                text = dark."onBackground";
                subtext1 = dark."onSurfaceVariant";
                subtext0 = dark."outline";
                overlay2 =
                  mix
                  dark."surface"
                  dark."outline"
                  86;
                overlay1 =
                  mix
                  dark."surface"
                  dark."outline"
                  71;
                overlay0 =
                  mix
                  dark."surface"
                  dark."outline"
                  57;
                surface2 =
                  mix dark."surface"
                  dark."outline"
                  43;
                surface1 =
                  mix
                  dark."surface"
                  dark."outline"
                  29;
                surface0 =
                  mix dark."surface"
                  dark."outline"
                  14;
                base = dark."surface";
                mantle =
                  # darken(
                  dark."surface";
                # , 0.03);
                crust =
                  # darken(
                  dark."surface";
                # , 0.05);
                success = "B5CCBA";
                onSuccess = "213528";
                successContainer = "374B3E";
                onSuccessContainer = "D1E9D6";
              })
          )}'';
      }
    )
  ];
}
