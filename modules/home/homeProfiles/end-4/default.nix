{
  osConfig,
  pkgs,
  options,
  extraInputs,
  lib,
  ...
}: let
  agsP =
    extraInputs.ags.packages.${pkgs.system}.default.override {
      extraPackages = with pkgs; [
        gtksourceview
        gtksourceview4
        webkitgtk
        webp-pixbuf-loader
      ];

      # nativeBuildInputs = with pkgs; [makeWrapper ];
    };
  agsPackage = pkgs.writeShellScriptBin "ags" ''
    PATH="$PATH:${lib.makeBinPath ( with pkgs;[
    glib
    ddcutil
    dart-sass
    brightnessctl
    ])}"
    ${agsP}/bin/ags "$@"
  '';
  mypython = pkgs.python3.withPackages (p:
    with p; [
      pip
      pillow
      psutil
      setproctitle
      materialyoucolor
      material-color-utilities
      pywayland
      libsass
      numpy
    ]);
  imupulseAgs = with pkgs;
    {agsPackage ? ags_1, ...}:
      stdenv.mkDerivation {
        pname = "illogical-impulse-ags";
        version = "latest";

        src = fetchFromGitHub {
          owner = "bigsaltyfishes";
          repo = "dots-hyprland";
          rev = "f3881b9bcc67edf268c5e68fa6c51c01d7d9fafe";
          sha256 = "sha256-0ihJT6gkb+pTGYVdSySWDTzFEikjgNiQhvt+6+c3rZQ=";
        };

        nativeBuildInputs = [makeWrapper mypython];
        patches =
          lib.optional
          config.services.power-profiles-daemon.enable
          ./powerprofiles.patch;

        buildPhase = ''
          mkdir -p $out
          rm .config/ags/user_options.jsonc
          rm .config/ags/scss/main.scss
          ${lib.optionalString isMatugen
            "rm .config/ags/scss/fallback/_material.scss"}
          cp -r .config/ags/* $out/
        '';

        fixupPhase = ''

          for prog in $(find $out -type f -name "*.py" -executable); do
          patchShebangs $prog
          done
          # Wrap all scripts to use the correct environment
          for prog in $(find $out -type f -name "*.sh" -executable); do
            if grep -q 'agsv1' $prog ; then
              substituteInPlace $prog --replace 'agsv1' "${agsPackage}/bin/ags"
            fi
            wrapProgram $prog \
              --prefix PATH : ${lib.makeBinPath [
            bc
            xdg-user-dirs
            pywal
            dart-sass
            gradience
          ]}
          done
        '';

        meta = {
          description = "Illogical Impulse AGS";
          homepage = "https://github.com/end-4/dots-hyprland";
          license = lib.licenses.gpl3;
        };
      };

  config = osConfig;
  isMatugen = config.programs ? "matugen";
  colors = config.programs.matugen.theme.colors."${config.stylix.polarity}";
in {
  # options.programs.end4 = {};
  config = lib.mkMerge [
    (lib.optionalAttrs (options ? "persistence") {
      persistence.cache.directories = [
        ".local/state/ags"
      ];
    })
    {
      wayland.windowManager.hyprland.settings.exec-once = lib.mkAfter [
        "ags"
      ];
      home.file = {
        # "~/.config/ags/modules/.configuration/default_options.jsonc".text = ;
        ".config/ags" = {
          source = "${imupulseAgs {inherit agsPackage;}}";
          recursive = true;
        };
        ".config/ags/scss/main.scss".text =
          #scss
          ''

            *:not(popover) { all: unset; }

            // Colors
            @import 'material'; // Material colors
            @import './colors'; // Global color definitions. Uses material colors as base.
            @import './lib_mixins';
            @import 'lib_mixins_overrides';
            @import './lib_classes';
            @import './common'; // Context menu n stuff

            // Components
            @import './bar';
            @import './cheatsheet';
            @import './desktopbackground';
            @import './dock';
            @import './osd';
            @import './overview';
            @import './osk';
            @import './sidebars';
            @import './session';
            @import './notifications';

            // Music is put last as it might mess stuff up with pywal
            @import './music'; // Everything related to music is here

            // Classes for interaction
            .growingRadial {
                transition: 300ms cubic-bezier(0.2, 0.0, 0, 1.0);
            }
            .fadingRadial {
                transition: 50ms cubic-bezier(0.2, 0.0, 0, 1.0);
            }
            .sidebar-pinned {
                margin: 0rem;
                border-radius: 0rem;
                border-bottom-right-radius: $rounding_large;
                border: 0rem solid;
            }
            .bar-bg, .bar-bg-focus {
              margin-bottom: -3px;
            }
            .corner {
              border-radius: 3rem;
              -gtk-outline-radius: 3rem;
            }
          '';
      };
      home.packages = with pkgs; [
        agsPackage
        noto-fonts
        noto-fonts-cjk-sans
        google-fonts
        cascadia-code
        material-symbols
      ];
    }
    (lib.optionalAttrs isMatugen {
      home.file = {
        ".config/ags/scss/fallback/_material.scss".text =
          #scss
          ''
            $darkmode: True;
            $transparent: True;
            $primary_paletteKeyColor: ${colors.primary};
            $secondary_paletteKeyColor: ${colors.secondary};
            $tertiary_paletteKeyColor: #${colors.tertiary};
            $neutral_paletteKeyColor: #84727A;
            $neutral_variant_paletteKeyColor: #86717B;
            $background: ${colors.background};
            $onBackground: ${colors.on_background};
            $surface: ${colors.surface};
            $surfaceDim: ${colors.surface_dim};
            $surfaceBright: ${colors.surface_bright};
            $surfaceContainerLowest: ${colors.surface_container_lowest};
            $surfaceContainerLow: ${colors.surface_container_low};
            $surfaceContainer: ${colors.surface_container};
            $surfaceContainerHigh: ${colors.surface_container_high};
            $surfaceContainerHighest: ${colors.surface_container_highest};
            $onSurface: ${colors.on_surface};
            $surfaceVariant: ${colors.surface_variant};
            $onSurfaceVariant: ${colors.on_surface_variant};
            $inverseSurface: ${colors.inverse_surface};
            $inverseOnSurface: ${colors.inverse_on_surface};
            $outline: ${colors.outline};
            $outlineVariant: ${colors.outline_variant};
            $shadow: ${colors.shadow};
            $scrim: ${colors.scrim};
            $surfaceTint: ${colors.surface_tint};
            $primary: ${colors.primary};
            $onPrimary: ${colors.on_primary};
            $primaryContainer: ${colors.primary_container};
            $onPrimaryContainer: ${colors.on_primary_container};
            $inversePrimary: ${colors.inverse_primary};
            $secondary: ${colors.secondary};
            $onSecondary: ${colors.on_secondary};
            $secondaryContainer: ${colors.secondary_container};
            $onSecondaryContainer: ${colors.on_secondary_container};
            $tertiary: ${colors.tertiary};
            $onTertiary: ${colors.on_tertiary};
            $tertiaryContainer: ${colors.tertiary_container};
            $onTertiaryContainer: ${colors.on_tertiary_container};
            $error: ${colors.error};
            $onError: ${colors.on_error};
            $errorContainer: ${colors.error_container};
            $onErrorContainer: ${colors.on_error_container};
            $primaryFixed: ${colors.primary_fixed};
            $primaryFixedDim: ${colors.primary_fixed_dim};
            $onPrimaryFixed: ${colors.on_primary_fixed};
            $onPrimaryFixedVariant: ${colors.on_primary_fixed_variant};
            $secondaryFixed: ${colors.secondary_fixed};
            $secondaryFixedDim: ${colors.secondary_fixed_dim};
            $onSecondaryFixed: ${colors.on_secondary_fixed};
            $onSecondaryFixedVariant: ${colors.on_secondary_fixed_variant};
            $tertiaryFixed: ${colors.tertiary_fixed};
            $tertiaryFixedDim: ${colors.tertiary_fixed_dim};
            $onTertiaryFixed: ${colors.on_tertiary_fixed};
            $onTertiaryFixedVariant: ${colors.on_tertiary_fixed_variant};
            $success: #B5CCBA;
            $onSuccess: #213528;
            $successContainer: #374B3E;
            $onSuccessContainer: #D1E9D6;
            $term0: #25161E;
            $term1: #FE45A7;
            $term2: #FFBAC0;
            $term3: #FFDDE2;
            $term4: #B3A3D5;
            $term5: #E491BE;
            $term6: #FFBA92;
            $term7: #EED1D6;
            $term8: #CAB4B7;
            $term9: #FFA6C9;
            $term10: #FFFCFF;
            $term11: #FFFFFF;
            $term12: #D5DAF9;
            $term13: #FFCBE2;
            $term14: #FFF9F8;
            $term15: #FFD8EB;
          '';
      };
    })
  ];
  imports = [
    ./_options.nix
  ];
}
