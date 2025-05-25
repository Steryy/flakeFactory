{
  osConfig,
  pkgs,
  inputs,
  # extraInputs,
  lib,
  ...
}: let
  config = osConfig;
  colors = config.programs.matugen.theme.colors."${config.stylix.polarity}";
  agsPackage =
    inputs.  ags.packages.${pkgs.system}.default.override {
      extraPackages = with pkgs; [
        gtksourceview
        gtksourceview4
        webkitgtk
        webp-pixbuf-loader
        ydotool
        dart-sass
      ];
    };
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
        patches = [
          ./powerprofiles.patch
        ];

        buildPhase = ''
          mkdir -p $out
          cp -r .config/ags/* $out/
          rm .config/ags/scss/fallback/_material.scss
          rm .config/ags/modules/.configuration/default_options.jsonc
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
            mypython
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
in {
  persistence.cache.directories = [
    ".local/state/ags"
  ];
  home.packages = with pkgs; [
    dart-sass
    gvfs
    # file-roller
    brightnessctl
    ddcutil
    grim
    hyprpicker
    # pavucontrol
    playerctl
    # swappy
    slurp
    swww
    wl-clipboard
    wf-recorder
    agsPackage
    # blueberry
    # pkgs.nautilus
    # yad

    # tools
    ripgrep
    jq
    libnotify
    glib
    foot
    kitty
    ydotool

    # themes
    adwaita-qt6
    adw-gtk3
    morewaita-icon-theme

    # fonts
    noto-fonts
    noto-fonts-cjk-sans
    google-fonts
    cascadia-code
    material-symbols
  ];
  imports = [
    ./_options.nix
  ];
  stylix.targets.gnome.enable = true;
  home.file = {
    # "~/.config/ags/modules/.configuration/default_options.jsonc".text = ;
    ".config/ags" = {
      source = "${imupulseAgs {inherit agsPackage;}}";
      recursive = true;
    };
    ".config/ags/scss/fallback/_material.scss".text =
      #scss
      ''
        $darkmode: True;
        $transparent: False;
        $primary_paletteKeyColor: #02DCFF;
        $secondary_paletteKeyColor: #597B8F;
        $tertiary_paletteKeyColor: #557AA1;
        $neutral_paletteKeyColor: #6D797D;
        $neutral_variant_paletteKeyColor: #6A7A7F;
        $background: #091518;
        $onBackground: #D8E5E9;
        $surface: #091518;
        $surfaceDim: #091518;
        $surfaceBright: #2F3B3F;
        $surfaceContainerLowest: #051013;
        $surfaceContainerLow: #121D21;
        $surfaceContainer: #162125;
        $surfaceContainerHigh: #202C2F;
        $surfaceContainerHighest: #2B373A;
        $onSurface: #D8E5E9;
        $surfaceVariant: #3A494E;
        $onSurfaceVariant: #B9C9CE;
        $inverseSurface: #D8E5E9;
        $inverseOnSurface: #273236;
        $outline: #839398;
        $outlineVariant: #3A494E;
        $shadow: #000000;
        $scrim: #000000;
        $surfaceTint: #00D9FC;
        $primary: #00D9FC;
        $onPrimary: #003640;
        $primaryContainer: #004E5C;
        $onPrimaryContainer: #AAEDFF;
        $inversePrimary: #006879;
        $secondary: #A8CBE2;
        $onSecondary: #0D3446;
        $secondaryContainer: #2A4D60;
        $onSecondaryContainer: #C7E9FF;
        $tertiary: #A4CAF5;
        $onTertiary: #003256;
        $tertiaryContainer: #6F94BC;
        $onTertiaryContainer: #000000;
        $error: #FFB4AB;
        $onError: #690005;
        $errorContainer: #93000A;
        $onErrorContainer: #FFDAD6;
        $primaryFixed: #AAEDFF;
        $primaryFixedDim: #00D9FC;
        $onPrimaryFixed: #001F26;
        $onPrimaryFixedVariant: #004E5C;
        $secondaryFixed: #C4E7FF;
        $secondaryFixedDim: #A8CBE2;
        $onSecondaryFixed: #001E2C;
        $onSecondaryFixedVariant: #284B5D;
        $tertiaryFixed: #D0E4FF;
        $tertiaryFixedDim: #A4CAF5;
        $onTertiaryFixed: #001D34;
        $onTertiaryFixedVariant: #21496E;
        $success: #B5CCBA;
        $onSuccess: #213528;
        $successContainer: #374B3E;
        $onSuccessContainer: #D1E9D6;
        $term0: #0E1C21;
        $term1: #8383FF;
        $term2: #63DEDB;
        $term3: #75FCDD;
        $term4: #78B4C1;
        $term5: #7AAEEA;
        $term6: #81D7DE;
        $term7: #CCDBD5;
        $term8: #B1BCB5;
        $term9: #BCB9FF;
        $term10: #F4FFFE;
        $term11: #FFFFFF;
        $term12: #BEE3E8;
        $term13: #C8DAFF;
        $term14: #EAFEFF;
        $term15: #B0ECFC;


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
}
