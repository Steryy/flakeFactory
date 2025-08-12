{
  config,
  lib,
  ...
}: let
  inherit (lib.local.terranix.cloudGroups) shou;
in {
  perSystem = {pkgs, ...}: {
    config.terranix = let
      package = pkgs.opentofu.withPlugins (p: [
        p.external
        p.local
        p. null
        p.aws
      ]);
    in {
      terranixConfigurations.terraform-shou = {
        terraformWrapper.package = package;
        modules =
          [
            {
              terraform.required_providers.aws = {
                source = "hashicorp/aws";
                # version = "~> 4.90";
              };
            }
          ]
          ++ lib.collect (x: lib.isPath x) config.haumea.terranix.shou;
        extraArgs = {
          localLib = lib.local;
          inventory = shou config.flake.clan.inventory;
        };
        terraformWrapper.prefixText = ''
          AWS_ACCESS_KEY_ID="$(clan secrets get aws-access)"
          export AWS_ACCESS_KEY_ID
          AWS_SECRET_ACCESS_KEY="$(clan secrets get aws-secret)"
          export AWS_SECRET_ACCESS_KEY
        '';
      };
    };
  };
}
