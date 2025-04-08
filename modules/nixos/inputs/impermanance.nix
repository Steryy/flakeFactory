{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.persistence;
  # normalUsers = lib.attrNames (lib.filterAttrs (_: v: v.isNormalUser) config.users.users);
  dirDef = {
    dir,
    directories ? [],
    files ? [],
    userDirs ? [],
  }: {
    users = {
      files = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
      directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default =
          userDirs;
      };
    };

    files = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = files;
    };
    directories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default =
        directories
        #     [
        #   "/var/log"
        #   "/var/lib"
        # ]
        ;
    };
    directory = lib.mkOption {
      type = lib.types.str;
      default = dir;
    };
  };
in {
  options.persistence = {
    state = dirDef {
      dir = "/persist/@state";
      files = [
        "/etc/machine-id"
      ];
      directories = [
        "/var/log"
        "/var/lib/sbctl"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
      ];
      userDirs = [
        ".config/nix"
        ".local/state/nix"
        ".local/share/home-manager"
      ];
    };

    cache = dirDef {
      dir = "/persist/@cache";
      userDirs = [
        ".cache"
      ];
    };
    userNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      # default = normalUsers;
    };
    device = lib.mkOption {
      type = lib.types.str;
    };
    rollbacks = {
      btrfs = {
        enable = lib.mkEnableOption "btrfs rollback";
      };
    };
  };
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  config = {
    environment.persistence =
      lib.mapAttrs' (_: v: {
        name = v.directory;
        value = {
          inherit (v) directories;
          users =
            lib.genAttrs cfg.userNames (_: {
            });
        };
      })
      {
        inherit (cfg) cache state;
      };
    boot.initrd.systemd.services.rollback = lib.mkMerge [
      {
        wantedBy = ["initrd.target"];
        before = [
          "initrd-root-fs.target"
          "sysroot-var-lib-nixos.mount"
        ];
        after = ["sysroot.mount"];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
      }
      (
        lib.mkIf cfg.rollbacks.btrfs.enable {
          description = "Simplified Rollback BTRFS root subvolume to a pristine state";
          script = ''
            mkdir -p /btrfs_tmp
            mount ${cfg.device} -o subvol=/ /btrfs_tmp

            # Backup and rotate the /root subvolume
            if [[ -e /btrfs_tmp/root ]]; then
                mkdir -p /btrfs_tmp/old_roots
                timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
                mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
            fi

            # Function to recursively delete old subvolumes
            delete_subvolume_recursively() {
                IFS=$'\n'
                for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                    delete_subvolume_recursively "/btrfs_tmp/$i"
                done
                btrfs subvolume delete "$1"
            }

            # Remove /root backups older than 14 days
            for backup in /btrfs_tmp/old_roots/*; do
                if [[ -d "$backup" && $(find "$backup" -maxdepth 0 -mtime +14) ]]; then
                  echo "deleting $backup"
                    delete_subvolume_recursively "$backup"
                fi
            done

            # Create a fresh /root subvolume
            btrfs subvolume create /btrfs_tmp/root
            echo "Created fresh /root subvolume"


            # Unmount /btrfs_tmp after completing operations
            umount /btrfs_tmp
          '';
        }
      )
    ];
  };
}
