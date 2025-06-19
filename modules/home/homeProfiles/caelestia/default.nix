{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  packages = import ./_packages.nix {inherit pkgs inputs lib;};
  cfg = config.services.caelestia-shell;
in {
  options.services.caelestia-shell = {
    package = lib.mkOption {
      type = lib.types.package;
      default = packages.caelestia-shell;
      # default = pkgs.caelestia-shell;
    };
    finalPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
    };
    packageChanges = {
      patches = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
      };

      cmdOverrides = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.nullOr
          lib.types.str
        );
        default = {};
      };
    };
  };
  imports = [
    # ./packages.nix # Caelestia scripts and quickshell wrapper derivations
    ./config.nix # Configuration files and environment setup
  ];
  config = {
    services.caelestia-shell.finalPackage = let
      overrides = lib.mapAttrsToList (n: v:
        #bash
        ''
          if grep -qF '${n}' $prog ; then
            substituteInPlace $prog --replace '${n}' "${v}"
          fi
        '')
      (lib.filterAttrs (_: v: v != null) cfg.packageChanges.cmdOverrides);
    in
      cfg.package.overrideAttrs (oldAttrs: {
        patches =
          # []
          (oldAttrs.patches or []) ++ cfg.packageChanges.patches;
        fixupPhase = ''

          for prog in $(find $out -type f -name "*.qml" ); do
            ${lib.concatStringsSep "\n" overrides}
          done
        '';
      });
    services.caelestia-shell.packageChanges.patches = [
      ./patches/delbg.patch
      ./patches/noscheme.patch
      ./patches/storage.patch
      ./patches/uptime.patch
    ];
    services.caelestia-shell.packageChanges.cmdOverrides =
      lib.mapAttrs (n: v:
        if v == null
        then "${pkgs."${n}"}/bin/${n}"
        else v)
      {
        fish = null;
        sensors = "${pkgs.lm_sensors}/bin/sensors";
        app2unit = "${pkgs.gtk3}/bin/gtk-launch";
      };

    home.packages = with pkgs; [
      packages.quickshell-wrapped
      # config.programs.quickshell.finalPackage # Our wrapped quickshell
      # config.programs.quickshell.caelestia-scripts
      # Qt dependencies
      qt6.qt5compat
      qt6.qtdeclarative

      # Runtime dependencies
      # hyprpaper
      imagemagick
      wl-clipboard
      fuzzel
      socat
      foot
      jq
      python3
      # python3Packages.materialyoucolor
      # python3Packages.

      grim
      wayfreeze
      wl-screenrec
      dart-sass
      gtk3
      # inputs.astal.packages.${pkgs.system}.default

      # Additional dependencies
      lm_sensors
      curl
      material-symbols
      # material-symbols
      nerd-fonts.jetbrains-mono
      ibm-plex
      fd
      cava
      networkmanager
      bluez
      ddcutil
      brightnessctl
      packages. caelestia-quickshell

      # Wrapper for caelestia to work with quickshell
    ];

    # Systemd service
    systemd.user.services.caelestia-shell = {
      Unit = {
        Description = "Caelestia desktop shell";
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "exec";
        ExecStart = "${packages.quickshell-wrapped}/bin/qs -c caelestia";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    # Shell aliases
    home.shellAliases = {
      caelestia-shell = "qs -c caelestia";
      caelestia-edit = "cd ${config.xdg.configHome}/quickshell/caelestia && $EDITOR";
      caelestia = "${pkgs.writeShellScript "caelestia" ''
        if [[ "$1" == "wallpaper" && "$2" == "-f" ]]; then
          echo "Nuts"
          exit 0

        fi
        caelestia-quickshell "$@"

      ''}";
    };
  };

  # Main packages
}
