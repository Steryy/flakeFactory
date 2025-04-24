{ lib, config, options, ... }:
let
  cfg = config.clan.user-password.user;
  groupsExists = groups:
    lib.filter (g: lib.hasAttr g config.users.groups) groups;
in {

  config = lib.mkMerge [
    (lib.optionalAttrs (options ? "persistence") {
      persistence.userNames = [ cfg ];
    })
    {

      security.sudo.wheelNeedsPassword = false;
      nix.settings.trusted-users = [ "@wheel" cfg ];
      users.users."${cfg}" = {
        uid = 1000;
        isNormalUser = true;
        openssh.authorizedKeys.keys =
          config.users.users.root.openssh.authorizedKeys.keys;
        extraGroups = [ "wheel" "nix" ] ++ groupsExists [
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
