{
  config,
  lib,
  ...
}: let
  concMap = func: list:
    builtins.concatStringsSep "\n"
    (
      lib.flatten (
        map func list
      )
    );
  cfg = config.common.autoMount.luks;
in {
  options.common = {
    autoMount = {
      luks = lib.mkOption {
        default = [];
        type = lib.types.listOf (
          lib.types.submodule ({config, ...}: {
            options = {
              keyFiles = lib.mkOption {
                type = lib.types.listOf lib.types.str;
              };

              opts = lib.mkOption {
                default = [];
                type = lib.types.listOf lib.types.str;
              };
              volname = lib.mkOption {
                type = lib.types.str;
                internal = true;
                readOnly = true;
                default =
                  lib.replaceStrings ["-"] [""]
                  config.uuid;
              };

              mounts = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.submodule {
                    options = {
                      opts = lib.mkOption {
                        default = [];
                        type = lib.types.listOf lib.types.str;
                      };
                      path = lib.mkOption {
                        type = lib.types.str;
                      };
                    };
                  }
                );
              };
              uuid = lib.mkOption {
                type = lib.types.str;
              };
            };
          })
        );
      };
    };
  };
  config =
    lib.mkIf (cfg != [])
    {
      services.udev.extraRules =
        concMap (
          x: let
            cryptservice = volname: "systemd-cryptsetup@${volname}.service";
          in ''
            ACTION=="add", ENV{ID_FS_UUID}=="${x.uuid}", ENV{SYSTEMD_WANTS}+="${cryptservice x.volname}"
          ''
        )
        cfg;
      fileSystems = lib.pipe cfg [
        (map (
          x:
            map (mount: {
              name = mount.path;
              value = {
                device = "/dev/mapper/${x.volname}";
                options = (
                  ["noauto" "x-systemd.automount" "nofail"] ++ mount.opts
                );
              };
            })
            x.mounts
        ))
        lib.flatten
        lib.listToAttrs
      ];

      environment.etc.crypttab = {
        mode = "0600";
        text =
          concMap (
            x: let
              ops = builtins.concatStringsSep "," (["noauto"] ++ x.opts);
            in
              map (key: "${x.volname} UUID=${x.uuid} ${key} ${ops}") x.keyFiles
          )
          cfg;
      };
    };
}
