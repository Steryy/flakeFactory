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
in {
  options.services.gpgUnlock = {
    enable = lib.mkEnableOption "Automatic Unlocking of gpg";
    envfile = lib.mkOption {
      type = lib.types.str;
    };
  };
  config.systemd.user.services.gpgunlock = lib.mkIf config.services.gpgUnlock.enable {
    Unit = {
      Description = "Unlock gpg keys";

      Requires = "gpg-agent.service";
      After = "gpg-agent.service";
    };

    Install = {WantedBy = ["default.target"];};
    Service = {ExecStart = "${script}";};
  };
}
