{lib, ...}: let
  toMod = x: "mod-${lib.replaceStrings ["/" "."] ["-" "-"] x}";
  subDirs = list:
    if lib.length list > 0
    then list
    else [""];
  mkSubDir = {
    strPattern,
    subdir,
    name,
    ...
  }:
    lib.replaceStrings ["\${hostName}" "\${subDir}"] [name subdir] strPattern;

  mapSep = lib.concatMapStringsSep "\n";

  joinPath = dir: subDir:
    if subDir == ""
    then dir
    else "${dir}/${subDir}";
in {
  _class = "clan.service";
  manifest.name = "@local/ssh-share";
  roles.client = {
    interface = {
      options = {
        timer = {
          enable = lib.mkEnableOption "Whether get those files periodically";

          OnUnitActiveSec = lib.mkOption {
            type = lib.types.str;
            default = "2d";
          };
        };
        user = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };

        group = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        outDirectory = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        subDirectories = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
      };
      # These options can be set via 'roles.client.settings'
    };

    # Maps over all instances and produces one result per instance.
    perInstance = {
      instanceName,
      roles,
      settings,
      ...
    }: let
      serv = lib.head (lib.mapAttrsToList (n: v: {
          name = n;
          settings = v.settings;
        })
        roles.server.machines);
    in {
      nixosModule = {
        hostName,
        pkgs,
        ...
      }: let
        str = "sshd-get-${instanceName}";
      in {
        systemd = lib.mkIf (serv.name
          != hostName) {
          timers."${str}" = lib.mkIf (settings.timer.enable) {
            wantedBy = ["timers.target"];
            timerConfig = {
              OnBootSec = "10min";
              inherit (settings.timer) OnUnitActiveSec;
              # OnUnitActiveSec = "2d";
              Persistent = true;
            };
          };
          services."${str}" = {
            serviceConfig = {
              Type = "oneshot";
              ExecStart = let
                user =
                  if settings.user != null
                  then settings.user
                  else serv.settings.user;
                remote = "${serv.settings.user}@${serv.name}";

                local =
                  if settings.outDirectory != null
                  then settings.outDirectory
                  else serv.settings.srcDirectory;
                # mode =
                #   if serv.settings.writeMode
                #   then "${local} ${remote}"
                #   else "${remote} $local";";
              in ''
                mkdir -p ${local}
                chown -R ${user}${
                  if settings.group != null
                  then ":${settings.group}"
                  else ""
                } ${local}
                ${
                  mapSep (subdir: let
                    subdir' = mkSubDir (serv.settings
                      // {
                        inherit subdir;
                        name = hostName;
                      });
                    remote' = "${remote}::${toMod subdir}";
                    local' = joinPath local subdir';
                  in ''
                    ${pkgs.rsync}/bin/rsync -avz  "ssh -i /etc/ssh/ssh_host_ed25519_key"  ${
                      if serv.settings.writeMode
                      then "${local'} ${remote'}"
                      else "${remote'} ${local'}"
                    }
                  '') (subDirs settings.subDirectories)
                }
              '';
            };
          };
        };
      };
    };
  };

  roles.server = {
    interface = {
      options = {
        user = lib.mkOption {
          type = lib.types.str;
        };
        srcDirectory = lib.mkOption {
          type = lib.types.str;
        };
        strPattern = lib.mkOption {
          type = lib.types.str;
          default = "\${subDir}";
          description = "String pattern that will replace \${x} with each machine name";
        };
        writeMode = lib.mkEnableOption "write only mode";
      };
    };
    perInstance = {
      roles,
      settings,
      instanceName,
      ...
    }: {
      nixosModule = {
        config,
        hostName,
        pkgs,
        ...
      }: let
        clients = lib.removeAttrs roles.client.machines [hostName];

        getSSH = name: let
          path = "${config.clan.core.settings.directory}/vars/per-machine/${name}/openssh/ssh.id_ed25519.pub/value";
        in
          if builtins.pathExists path
          then builtins.readFile path
          else null;
        forMachine = f:
          lib.mapAttrsToList (
            name: v: let
              subdirs = map (subdir: let
                subdir' = mkSubDir (settings
                  // {
                    inherit subdir name;
                  });
              in
                subdir')
              (subDirs v.settings.subDirectories);
            in
              f {} name subdirs
          )
          clients;
      in {
        options = {
          clan.services.ssh-share = {
            "${instanceName}".subdirs =
              lib.mkOption
              {
                type = lib.types.anything;
                readOnly = true;
                default = lib.flatten (
                  forMachine (_: subdirs: subDirs)
                );
              };
          };
        };
        config = {
          services.openssh.sftpServerExecutable = "internal-sftp";

          users.users."${settings.user}" = {
            shell = "${pkgs.bash}/bin/bash";

            openssh.authorizedKeys.keys = forMachine (
              name: subdirs
              : let
                cfg = pkgs.writeText "rsyncd.conf" ''
                  log file = /var/log/rsync/${name}/rsync.log
                  ${
                    mapSep (subdir: ''
                      [${toMod subdir}]
                        use chroot = false
                        path = ${joinPath settings.srcDirectory subdir}
                        read only = ${
                        if settings.writeMode
                        then "false"
                        else "true"
                      }
                    '')
                    subdirs
                  }
                '';

                cmd = ''command="rsync --config=${cfg} --server --daemon .",no-agent-forwarding,no-port-forwarding,no-user-rc,no-X11-forwarding,no-pty'';
              in "${cmd} ${getSSH name}"
            );
          };
        };
      };
    };
  };
}
