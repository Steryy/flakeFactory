{ inputs, lib, ... }:
let
in {
  imports = [
    inputs.git-hooks-nix.flakeModule
    inputs.devshell.flakeModule
    inputs.flake-root.flakeModule
  ];
  perSystem = { pkgs, config, inputs', ... }: {
    devshells.default = {
      env = [
        {
          name = "HTTP_PORT";
          value = 8080;
        }
        {
          name = "FLAKE_ROOT";
          eval = "$(${lib.getExe config.flake-root.package})";
        }
      ];
      commands = [{
        help = "Create users secrets";
        name = "userSecrets";
        command = "UserSecret.sh";

      }];
      packages = with pkgs; [
        disko
        config.packages.userSecrets
        sops
        nixos-anywhere
        nixos-facter
        inputs'.clan-core.packages.clan-cli
      ];

    };
  };
}
