{ inputs, config, flakeRoot, lib, osConfig, ... }:

let
  hostname = osConfig.networking.hostName;
  userName = config.home.username;
in {
  options.sops.secrets = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
      config = {
        format = "binary";
        sopsFile = flakeRoot
          + "/vars/per-machines/${hostname}/per-user/${userName}/${name}/secret";
      };
    }));
  };

  imports = [ inputs.sops-nix.homeManagerModules.sops ];
  config = lib.mkMerge [{
    sops = {
      age.keyFile = "${config.home.homeDirectory}/.ssh/keys/age.agekey";
    };
  }];
}
