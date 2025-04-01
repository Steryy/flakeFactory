{
  inputs,
  config,
  flakeRoot,
  lib,
  ...
}: let
  hostNames = lib.attrNames (
    lib.filterAttrs (_: v: v._secrets) config.easy-hosts.hostsBare
  );
in {
  imports = [
    inputs.agenix-rekey.flakeModule
  ];
  perSystem.
agenix-rekey.nixosConfigurations =
    lib.filterAttrs (n: _: lib.elem n hostNames)
    inputs.self.nixosConfigurations;
  easy-hosts.functionsList = [
    (x:
      if x._secrets
      then {
        modules = [
          inputs.agenix.nixosModules.default
          inputs.agenix-rekey.nixosModules.default
          ({options, ...}: {
            config = lib.optionalAttrs (options ? "home-manager") {
              home-manager.sharedModules = [
                ({...}: {
                  imports = [
                    inputs.agenix.homeManagerModules.age
                  ];
                })
              ];
            };
          })
          {
            age.rekey = {
              # hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOy3dC8cCbucumHphroUzZUTKkM0jL3mG3+tkeAWgIdX";
              masterIdentities = [
                {
                  identity = "~/.config/sops/age/keys.txt";
                  pubkey = "age1wlv6g495tdgsm3vyd28v48j3uydc0se00pa2fzr8w24uelw99fdsu2gr0a";
                }
              ];
              storageMode = "local";
              localStorageDir = flakeRoot + "/secrets/rekeyed/${config.networking.hostName}";
            };
          }
        ];
      }
      else {})
  ];
}
