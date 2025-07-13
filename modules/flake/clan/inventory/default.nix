{lib, ...}: let
  inherit (lib.local.keys) fileFromGroup;
in {
  clan = {
    inventory = {
      instances = {
        sshd = {
          module.name = "sshd";
          roles = {
            server = {
              tags.all = {};
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
        ts = {
          module = {
            name = "@local/tailscale";
            input = "self";
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
    };
  };
}
