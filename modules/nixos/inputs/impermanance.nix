{ extraInputs, lib, config, options, ... }:
let
  cfg = config.persistence;
  # normalUsers = lib.attrNames (lib.filterAttrs (_: v: v.isNormalUser) config.users.users);
  dirDef = { dir, directories ? [ ], files ? [ ], userDirs ? [ ], }: {
    users = {
      files = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = userDirs;
      };
    };

    files = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = files;
    };
    directories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = directories
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
  deviceDependency = if lib.hasPrefix "/dev/mapper/" cfg.device then
    "dev-mapper-${lib.removePrefix "/dev/mapper/" cfg.device}.device"
  else if lib.hasPrefix "/dev/disk/by-partlabel/" cfg.device then
    "dev-disk-by\\x2dpartlabel${
      lib.removePrefix "/dev/mapper/" cfg.device
    }.device"
  else
    throw "only /dev/mapper and /dev/disk/by-partlabel are supported";

in {
  options.persistence = {
    state = dirDef {
      dir = "/persist/@state";
      files = [ "/etc/machine-id" ];
      directories = [
        "/var/log"
        "/var/lib"
        "/etc/NetworkManager/system-connections"
        "/etc/ssh"
      ];
      userDirs = [ ];
    };

    cache = dirDef {
      dir = "/persist/@cache";
      userDirs = [ ".ssh" ".local/state/nix" ".cache" ];
    };
    userNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      # default = normalUsers;
    };

    device = lib.mkOption { type = lib.types.str; };
    rollbacks = { btrfs = { enable = lib.mkEnableOption "btrfs rollback"; }; };
  };
  imports = [ extraInputs.impermanence.nixosModules.impermanence ];
  config = lib.mkMerge [
    {

      boot.initrd.systemd.services.clean = {
        wantedBy = [ "initrd.target" ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        # requires = [ deviceDependency ];
        #
        after = [ deviceDependency ];
      };

    }
    (lib.mkIf cfg.rollbacks.btrfs.enable {
      boot.initrd.systemd.services.clean = {
        description = "Rollback BTRFS root subvolume to a pristine state";
        script = ''
          mkdir /btrfs_tmp
          mount ${cfg.device} -t btrfs /btrfs_tmp
          if [[ -e /btrfs_tmp/root ]]; then
              mkdir -p /btrfs_tmp/old_roots
              timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
              mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
          fi

          delete_subvolume_recursively() {
              IFS=$'\n'
              for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                  delete_subvolume_recursively "/btrfs_tmp/$i"
              done
              btrfs subvolume delete "$1"
          }

          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
              delete_subvolume_recursively "$i"
          done

          btrfs subvolume create /btrfs_tmp/root
          umount /btrfs_tmp
        '';
      };
    })
    {
      programs.fuse.userAllowOther = true;
      environment.persistence = lib.mapAttrs' (_: v: {
        name = v.directory;
        value = {
          hideMounts = true;
          inherit (v) directories;
          users = lib.genAttrs cfg.userNames
            (_: { inherit (v.users) files directories; });
        };
      }) { inherit (cfg) cache state; };
    }
  ];
}
