{
  config,
  # inputs,
  # cell,
  pkgs,
  lib,
  ...
}: let
  bashscr = pkgs.writeShellScript "Scrip.sh" ''
    for i in {0..4}; do
    export DISPLAY=":$i"
    printf "%s" "$1" |  ${pkgs.xclip}/bin/xclip -selection clipboard
    done
  '';
  cfg = config.services.wineClip;
in {
  options.services.wineClip = {
    enable = lib.mkEnableOption "wineClip";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      xclip
      wl-clipboard
    ];
    systemd.user.services = lib.mkIf (config.services.wineClip.enable) {
      wineClip = {
        Unit = {
          Description = "Simple tool to sync clipbaord";
          Documentation = "https://github.com/Alexays/Waybar/wiki";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session-pre.target"];
        };

        Service = {
          ExecStart =
            pkgs.writeShellScript "evalu"
            "
         wl-paste -t text -w xargs ${bashscr}
         ";
          # Restart = "on-failure";
          KillMode = "mixed";
        };

        Install = {WantedBy = ["graphical-session.target"];};
      };
    };
  };
}
