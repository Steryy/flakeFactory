{
  config,
  pkgs,
  lib,
  ...
}: let
  pkg = config.programs.gpg.package;

  passp = "${pkg}/bin/libexec/gpg-preset-passphrase";
  script = pkgs.writeShellScript "unlockMeDAddy.sh" ''
    source "${config.services.gpgUnlock.envfile}"

    export GPG_AGENT_INFO=$(${pkg}/bin/gpgconf --list-dirs agent-socket )
    for key in "''${GRIPS[@]}"; do
          ${passp}   -P"$GPG_PASS" --preset "$key" &&  echo "Unlocking $key " || echo "Failed unlocking $key"
    done
  '';
  servicename = "gpgunlock";
in {
  options.services.gpgUnlock = {
    enable = lib.mkEnableOption "Automatic Unlocking of gpg";
    envfile = lib.mkOption {
      type = lib.types.str;
    };
  };
  config = lib.mkIf config.services.gpgUnlock.enable {
    systemd.user.services."${servicename}" = {
      Unit = {
        Description = "Unlock gpg keys";

        Requires = ["gpg-agent.service"];
        After = ["gpg-agent.service"];
      };

      Install = {WantedBy = ["default.target"];};
      Service = {ExecStart = "${script}";};
    };
    systemd.user.services.gpg-agent.Service = {
      ExecReloadPost = "${pkgs.systemd}/bin/systemctl --user restart ${servicename}.service";

    };
  };
}
