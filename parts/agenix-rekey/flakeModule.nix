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
  flakeConfg = config.flake;
in {
  imports = [
    inputs.agenix-rekey.flakeModule
  ];

  perSystem = {...}: {
    agenix-rekey.nixosConfigurations =
      lib.filterAttrs (n: _: lib.elem n hostNames)
      flakeConfg.nixosConfigurations;
  };
  easy-hosts.functionsList = [
    (x: let
      secDir = flakeRoot + "/vars/${x._hostName}";
      commonConf = {
        masterIdentities = [
          {
            identity = flakeRoot + "/privkey.age";
          }
        ];
        storageMode = "local";
      };
    in
      if x._secrets
      then {
        modules = [
          inputs.agenix.nixosModules.default
          inputs.agenix-rekey.nixosModules.default
          ({options, ...}: {
            config = lib.optionalAttrs (options ? "home-manager") {
              home-manager.sharedModules = [
                ({config, ...}: {
                  imports = [
                    inputs.agenix-rekey.homeManagerModules.default
                    inputs.agenix.homeManagerModules.age
                  ];
                  age.rekey = let
                    secretDir = secDir + "/users/${config.home.username}";
                  in
                    commonConf
                    // {
                      generatedSecretsDir = secretDir + "/generated";

                      secretsDir = secretDir + "/secrets";
                      localStorageDir = secretDir + "/local";
                    };
                })
              ];
            };
          })
          ({config, ...}: {
            age.identityPaths = map (x: x.path) config.services.openssh.hostKeys;
          })
          {
            # age.identityPaths
            age.rekey = let
              key = secDir + "/pubkey.txt";
            in
              commonConf
              // {
                generatedSecretsDir = secDir + "/generated";

                secretsDir = secDir + "/secrets";
                localStorageDir = secDir + "/local";
                hostPubkey = lib.throwIfNot (lib.pathExists key) "${x._hostName} dont have public key set" (lib.readFile key);
              };
          }
        ];
      }
      else {})
  ];
}
