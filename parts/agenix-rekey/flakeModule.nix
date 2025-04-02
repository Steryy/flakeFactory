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

  perSystem = {...}: {
    agenix-rekey.nixosConfigurations = lib.filterAttrs (n: _: lib.elem n hostNames); # (not technically needed, as it is already the default)
  };
  easy-hosts.functionsList = [
    (x: let
      key = config.haumea.publicVars."${x._hostName}".pubkey;
    in
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
          (_: {
            age.rekey = {
              hostPubkey = lib.throwIfNot (key ? "value") "${x._hostName} dont have public key set" key.value;
              masterIdentities = [
                {
                  identity = "~/.config/sops/age/keys.txt";
                  pubkey = "age1wlv6g495tdgsm3vyd28v48j3uydc0se00pa2fzr8w24uelw99fdsu2gr0a";
                }
              ];
              storageMode = "local";
              localStorageDir = flakeRoot + "/vars/secrets/rekeyed/${x._hostName}";
            };
          })
        ];
      }
      else {})
  ];
}
