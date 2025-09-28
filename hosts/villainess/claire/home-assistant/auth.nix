{
  pkgs,
  lib,
  ...
}: let
  ldap_auth_script_repo = pkgs.fetchFromGitHub {
    owner = "lldap";
    repo = "lldap";
    rev = "v0.6.2";
    hash = "sha256-UBQWOrHika8X24tYdFfY8ETPh9zvI7/HV5j4aK8Uq+Y=";
  };

  ldap_auth_script = pkgs.writeShellScriptBin "ldap_auth.sh" ''
    export PATH=${pkgs.gnused}/bin:${pkgs.curl}/bin:${pkgs.jq}/bin
    exec ${pkgs.bash}/bin/bash ${ldap_auth_script_repo}/example_configs/lldap-ha-auth.sh $@
  '';
  # TODO: Use host from lldap clan service
  cfg = {
    ldap = {
      enable = true;
      host = "127.0.0.1";
      port =
        17170;
    };
  };
in {
  services.home-assistant.config.homeassistant.auth_providers =
    [
      {
        type = "homeassistant";
      }
    ]
    ++ (lib.optionals cfg.ldap.enable [
      {
        type = "command_line";
        command = ldap_auth_script + "/bin/ldap_auth.sh";
        args = ["http://${cfg.ldap.host}:${toString cfg.ldap.port}" "homeassistant_user" "homeassistant_admin"];
        meta = true;
      }
    ]);
}
