{
  lib,
  config,
  ...
}: let
  inherit (lib.local.tags) toInventory getAll groups;
  allTags = getAll config.clan.inventory.machines;
  toInv = toInventory allTags;
in {
  clan.inventory.instances = {
    acme = {
      module = {
        name = "@local/ssh-share";
      };
      roles = {
        client = {
          extraModules = [
            {
              users.users.acme = {
                home = "/var/lib/acme";
                homeMode = "755";
                group = "acme";
                isSystemUser = true;
              };
              users.groups.acme = {};
            }
          ];
          tags =
            toInv groups.server;
          settings = {
            outDirectory = "/var/lib/acme";
            subDirectories = ["ts.stanley-dev.net"];
            timer.enable = true;
            # subDirectories =
          };
        };
        server = {
          settings = {
            srcDirectory = "/var/lib/acme";
            strPattern = "$\{hostName}.\${subDir}";
            user = "acme";
          };
          extraModules = [
            ../../../nixos/services/acme.nix
          ];
          machines.villainess-claire = {};
        };
      };
    };
    tailscale = {
      module = {
        name = "@local/ssh-share";
      };
      roles = {
        client = {
          tags.all = {};
          settings = {
            user = "tailscale";
            outDirectory = "/var/lib/tailscale/preAuth";
          };
        };
        server = {
          settings = {
            srcDirectory = "/var/lib/headscale/preAuth";
            strPattern = "$\{hostName}";
            user = "headscale";
          };
          machines.shou-jeannette = {};
        };
      };
    };
  };
}
