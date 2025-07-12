{
  config,
  pkgs,
  extraInputs,
  inputs,
  lib,
  ...
}: let
  packages = import ./_packages.nix {inherit pkgs  lib;};
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
    app2unit = lib.mkOption {
      type = lib.types.package;
    };

    quickshellPackage = lib.mkOption {
      type = lib.types.package;
      default =
        extraInputs.quickshell.packages."${pkgs.system}".default;
    };

    quickshellFinal = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf (
        lib.types.package
      );
      default = [];
    };
    packageChanges = {
      patches = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
      };
    };
  };
  imports = [
    # ./packages.nix # Caelestia scripts and quickshell wrapper derivations
    ./config.nix # Configuration files and environment setup
  ];
  config = {
    services.caelestia-shell.finalPackage = cfg.package.overrideAttrs (oldAttrs: {
      patches =
        (oldAttrs.patches or []) ++ cfg.packageChanges.patches;
    });
    services.caelestia-shell.packageChanges.patches = [
      ./patches/delbg.patch
      # ./patches/noscheme.patch
      ./patches/storage.patch
      ./patches/uptime.patch
    ];

    services.caelestia-shell.quickshellFinal =
      pkgs.runCommand "quickshell-wrapped" {
        nativeBuildInputs = [pkgs.makeWrapper];
      } ''
        mkdir -p $out/bin
        makeWrapper ${cfg.quickshellPackage}/bin/qs $out/bin/qs \
          --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
          --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
          --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
          --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
          --prefix PATH : ${lib.makeBinPath ([pkgs.fd pkgs.coreutils] ++ cfg.extraPackages)} 
      '';

    services.caelestia-shell.extraPackages = with pkgs; [
      cfg.app2unit
      lm_sensors
      fish
      curl
      cava
      ibm-plex
      imagemagick
      networkmanager
      bluez
      brightnessctl
    ];

    home.packages = with pkgs; [
      cfg.quickshellFinal
      material-symbols
      material-design-icons
      packages. caelestia-quickshell
    ];

    # Systemd service
    systemd.user.services.caelestia-shell = {
      Unit = {
        Description = "Caelestia desktop shell";
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "exec";
        ExecStart = "${config.services.caelestia-shell.quickshellFinal}/bin/qs -c caelestia";
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
    };
  };

  # Main packages
}
