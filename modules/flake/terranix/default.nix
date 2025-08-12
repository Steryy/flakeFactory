{
  lib,
  inputs,
  config,
  ...
}: {
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
          name' = lib.removePrefix "terraform-" name;
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
                terraform.required_providers = {
                  local.source = "hashicorp/local";
                  # null.source = "hashicorp/null";
                  external.source = "hashicorp/external";
                };
              }
              {
                backend.git = {
                  owner = "Steryy";
                  repo = "flakeFactory";
                  path = "${name'}.state.json";
                };
              }
            ];
            workdir = "vars/terraform/${name'}";
            terraformWrapper.extraRuntimeInputs = [
              inputs'.clan-core.packages.default
              pkgs.nixos-facter
            ];
            terraformWrapper. suffixText = ''
              ${pkgs.terraform-backend-git}/bin/terraform-backend-git stop
            '';
            terraformWrapper.prefixText = ''
              TF_BACKEND_HTTP_ENCRYPTION_PASSPHRASE="$(clan secrets get tf-passphrase)"
              export TF_BACKEND_HTTP_ENCRYPTION_PASSPHRASE
              ${pkgs.terraform-backend-git}/bin/terraform-backend-git &

            '';
          };
        }));
    };
  };
}
