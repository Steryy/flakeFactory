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
      packages = with pkgs; [
        disko
        sops
        nixos-anywhere
        nixos-facter
        inputs'.clan-core.packages.clan-cli
      ];

    };
  };
}
