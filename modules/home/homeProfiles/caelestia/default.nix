{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  cfg = config.services.caelestia-shell;
in {
  options.services.caelestia-shell = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.caelestia-shell.packages."${pkgs.system}".default;
      # default = pkgs.caelestia-shell;
    };
  };

  config = {
    xdg.userDirs.extraConfig = {
      CAELESTIA_DATA = ".local/share/caelestia";
      CAELESTIA_STATE = ".local/state/caelestia";
      CAELESTIA_CONFIG = ".config/caelestia";
    };
    home.packages = [
      cfg.package
    ];

    # Systemd service
    systemd.user.services.caelestia-shell = {
      Unit = {
        Description = "Caelestia desktop shell";
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "exec";
        ExecStart = "${cfg.package}/bin/caelestia-shell";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    # Shell aliases
  };

  # Main packages
}
