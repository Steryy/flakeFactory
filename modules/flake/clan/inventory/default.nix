{lib, ...}: let
  inherit (lib.local.keys) fileFromGroup;
in {
  clan = {
    inventory = {
      instances = {
        ts = {
          module = {
            name = "@local/tailscale";
          };
          roles = {
            client = {
              tags.all = {};
            };
            headscale = {
              settings = {
                tld = "ts.stanley-dev.net";
                listeningDomain = "zt.stanley-dev.net";
              };
              machines.shou-jeannette = {};
            };
          };
        };
      };
      services = {
        user-password.default = {roles.default.tags = ["kami"];};
        state-version.default = {roles.default.tags = ["all"];};

        sshd.all.roles.server = {
          tags = ["all"];
          extraModules = [
            {
              users.users.root.openssh.authorizedKeys.keys = fileFromGroup {
                group = "admin";
                file = "sshkey";
              };
            }
          ];
        };
      };
    };
  };
}
