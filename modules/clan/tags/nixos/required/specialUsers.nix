{
  lib,
  config,
  options,
  ...
}: let
  usernames = lib.pipe config.clan.core.vars.generators [
    lib.attrNames
    (lib.filter (lib.hasPrefix "user-password-"))
    (map (x: lib.removePrefix "user-password-" x))
  ];
  # cfg = config.users.defaultUser;
  groupsExists = groups:
    lib.filter (g: lib.hasAttr g config.users.groups) groups;
in {
  config = lib.mkMerge [
    (lib.optionalAttrs (options ? "persistence") {
      persistence.userNames = usernames;
    })
    {
      security.sudo.wheelNeedsPassword = false;
      nix.settings.trusted-users = ["@wheel"] ++ usernames;
      users.users = lib.listToAttrs (map (x: {
          name = x;
          value = {
            openssh.authorizedKeys.keys =
              config.users.users.root.openssh.authorizedKeys.keys;

            extraGroups =
              ["wheel" "nix"]
              ++ groupsExists [
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
        })
        usernames);
    }
  ];
}
