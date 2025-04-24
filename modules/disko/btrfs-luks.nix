{ lib, config, ... }:
# {diskoLuks ? {}}:
let
  conf = config.diskoTemplate;
  # conf = diskoLuks;
in {
  options = { diskoTemplate = lib.mkOption { type = lib.types.attrs; }; };
  config = {
    disko.devices = builtins.mapAttrs (n: cfg:
      let
        # cdev = cfg.label;
        keyFile = lib.head cfg.keyFiles;
        rest = lib.tail cfg.keyFiles;

        passFile = cfg.passFile;
        keyFileSize = cfg.keyFileSize;
        labels = map (x: "${x}") cfg.labels;
        bootLabel = lib.lists.elemAt labels 0;
        luksLabel = lib.lists.elemAt labels 1;
        mapperLabel = lib.lists.elemAt labels 2;
        # label1
      in {
        "${n}" = {
          type = "disk";
          device = cfg.device;

          # device = "/dev/vdb";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1024M";
                type = "EF00";
                label = "${bootLabel}";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              luks = {
                size = "100%";
                label = "${luksLabel}";
                content = {
                  type = "luks";
                  name = "${mapperLabel}";

                  settings = {
                    bypassWorkqueues = true;
                    allowDiscards = true;
                    inherit keyFileSize;
                    keyFileTimeout = 20;
                    inherit keyFile;
                  };
                  additionalKeyFiles = rest;
                  postCreateHook = ''
                      cryptsetup luksAddKey --key-file ${keyFile} \
                      --keyfile-size ${toString keyFileSize} \
                    /dev/disk/by-partlabel/${luksLabel} ${passFile}
                  '';
                  content = {
                    type = "${cfg.fsType}";

                    extraArgs = [ "-L" "nixos" "-f" ];
                    subvolumes = cfg.additionalMount // {
                      "${cfg.root}" = {
                        mountpoint = "/";
                        mountOptions = [ "compress=zstd" "noatime" ];
                      };
                      "@nix" = {
                        mountpoint = "/nix";
                        mountOptions = [ "compress=zstd" "noatime" ];
                      };
                    };
                  };
                };
              };
            };
          };
        };
      }) conf;
  };
}
