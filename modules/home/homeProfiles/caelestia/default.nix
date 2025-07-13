{
  config,
  pkgs,
  extraInputs,
  inputs,
  lib,
  ...
}: let
  packages = inputs.self.packages."${pkgs.system}" ;
  cfg = config.services.caelestia-shell;

  caelestia-quickshell = pkgs. writeScriptBin "caelestia-quickshell" ''
    #!${pkgs.fish}/bin/fish

    # Override for caelestia shell commands to work with quickshell
    set -l original_caelestia ${packages.caelestia-cli}/bin/caelestia

    if test "$argv[1]" = "shell" -a -n "$argv[2]"
        set -l cmd $argv[2]
        set -l args $argv[3..]

        switch $cmd
            case "show" "toggle"
                if test -n "$args[1]"
                    exec qs -c caelestia ipc call drawers $cmd $args[1]
                else
                    echo "Usage: caelestia shell $cmd <drawer>"
                    exit 1
                end
            case "media"
                if test -n "$args[1]"
                    set -l action $args[1]
                    switch $action
                        case "play-pause"
                            exec qs -c caelestia ipc call mpris playPause
                        case '*'
                            exec qs -c caelestia ipc call mpris $action
                    end
                else
                    echo "Usage: caelestia shell media <action>"
                    exit 1
                end
            case '*'
                # For other shell commands, try the original
                exec $original_caelestia $argv
        end
    else
        # For non-shell commands, use the original
        exec $original_caelestia $argv
    end
  '';
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
      # ./patches/uptime.patch
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
      caelestia-quickshell
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
