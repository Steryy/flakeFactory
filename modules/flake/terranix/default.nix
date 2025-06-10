{
  lib,
  inputs,
  ...
}: let
in {
  imports = [
    inputs.terranix.flakeModule
  ];
  perSystem = {
    inputs',
    pkgs,
    ...
  }: {
    terranix = let
      package = pkgs.opentofu.withPlugins (p: [
        p.external
        p.local
        p.null
        p.aws
        p.azurerm
      ]);
    in {
      # `nix run .#dns` will fail
      # This is used as a module from the `terraform` terranix config

      terranixConfigurations.terraform = {
        workdir = "terraform";
        terraformWrapper.package = package;
        terraformWrapper.extraRuntimeInputs = [inputs'.clan-core.packages.default];
        terraformWrapper.prefixText = ''

          TF_VAR_passphrase="$(clan secrets get tf-passphrase)"
          export TF_VAR_passphrase
          AWS_ACCESS_KEY_ID="$(clan secrets get aws-access)"
          export AWS_ACCESS_KEY_ID
          AWS_SECRET_ACCESS_KEY="$(clan secrets get aws-secret)"
          export AWS_SECRET_ACCESS_KEY

          TF_ENCRYPTION=$(cat <<EOF
          key_provider "pbkdf2" "state_encryption_password" {
            passphrase = "$TF_VAR_passphrase"
          }
          method "aes_gcm" "encryption_method" {
            keys = "\''${key_provider.pbkdf2.state_encryption_password}"
          }
          state {
            enforced = true
            method = "\''${method.aes_gcm.encryption_method}"
          }
          EOF
          )

          # shellcheck disable=SC2090
          export TF_ENCRYPTION
        '';
      };
    };
  };
}
