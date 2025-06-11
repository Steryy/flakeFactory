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
    config = {
      terranix.exportDevShells = false;
    };
    options.terranix.terranixConfigurations = lib.mkOption {
      type =
        lib.types.attrsOf
        (lib.types.submodule ({name, ...} @ submod: let
          mkTfScript = name: text:
            pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [submod.config.result.terraformWrapper];
              text = ''
                mkdir -p ${submod.config.workdir}
                ln -sf ${submod.config.result.terraformConfiguration} ${submod.config.workdir}/config.tf.json
                ${text}
              '';
            };
          tfBinaryName = submod.config.result.terraformWrapper.meta.mainProgram;
        in {
          options = {
            result = lib.mkOption {
              type = lib.types.submodule ({options, ...}: {
                config = {
                  scripts =
                    options.scripts.default
                    // {
                      program = mkTfScript "program" ''
                        ${tfBinaryName} "$@"
                      '';
                    };
                };
              });
            };
          };
          config = {
            modules = [
              ./_git.nix
              {
                backend.git = {
                  owner = "Steryy";
                  repo = "flakeFactory";
                  path = "${name}.state.json";
                };
              }
            ];
            workdir = "vars/terraform/${name}";
            terraformWrapper.extraRuntimeInputs = [inputs'.clan-core.packages.default];
            terraformWrapper. suffixText = ''
              ${pkgs.terraform-backend-git}/bin/terraform-backend-git stop
            '';
            terraformWrapper.prefixText = ''
              ${pkgs.terraform-backend-git}/bin/terraform-backend-git &

              TF_VAR_passphrase="$(clan secrets get tf-passphrase)"
              export TF_VAR_passphrase

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
        }));
    };
  };
}
