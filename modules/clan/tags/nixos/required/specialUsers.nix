{ lib, config, options, ... }:
let
  cfg = config.users.defaultUser;
  groupsExists = groups:
    lib.filter (g: lib.hasAttr g config.users.groups) groups;
in {
  options.users.defaultUser = lib.mkOption {
    type = lib.types.str;
  };

  config = lib.mkMerge [
    (lib.optionalAttrs (options.clan ? "user-password") {
      clan.user-password.user = cfg;
    })
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

          "adbusers"
          "audio"
          "cloudflared"
          "dialout"
          "docker"
          "git"
          "i2c"
          "input"
          "libvirtd"
          "lp"
          "lp"
          "mysql"
          "network"
          "networkmanager"
          "openvpn"
          "pipewire"
          "plugdev"
          "podman"
          "power"
          "scanner"
          "soundmodem"
          "systemd-journal"
          "tss"
          "uinput"
          "uiput"
          "video"
          "wireshark"
        ];
      };
    }
  ];
}
