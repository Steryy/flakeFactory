{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.common.specialUser;
  groupsExists = groups: lib.filter (g: lib.hasAttr g config.users.groups) groups;
in
{
  options.common.specialUser = lib.mkOption {
    type = lib.types.str;
  };

  config = lib.mkMerge [
    (lib.optionalAttrs (!(options ? "age")) {
      users.users."${cfg}".initialPassword = "changeme";
    })
    (lib.optionalAttrs (options ? "age") {
      age = {
        secrets = {
          "${cfg}pass" = { };
        };
      };
      users.users."${cfg}".passwordFile = config.age.secrets."${cfg}pass".path;
    })
    {
      users.users."${cfg}" = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = config.users.root.openssh.authorizedKeys.keys;
        extraGroups =
          [
            "wheel"
            "nix"
          ]
          ++ groupsExists [
            "network"
            "networkmanager"
            "systemd-journal"
            "audio"
            "pipewire"
            "video"
            "input"
            "uinput"
            "plugdev"
            "lp"
            "tss"
            "power"
            "wireshark"
            "mysql"
            "docker"
            "podman"
            "git"
            "libvirtd"
            "cloudflared"
            "uiput"
            "i2c"
            "dialout"
            "openvpn"
            "adbusers"
            "soundmodem"
          ];
      };
    }
  ];
}
