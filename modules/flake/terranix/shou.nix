{
  config,
  lib,
  ...
}: let
  # inherit (lib.local) getSpecialTag;
  inherit (lib.local) terranix;
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

      terranixConfigurations.shou = {
        terraformWrapper.package = package;
        modules = lib.collect (x: lib.isPath x ) config.haumea.terranix.shou;
        extraArgs = {
          localLib = lib.local;
          inventory = terranix config.clan.inventory "shou";
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
