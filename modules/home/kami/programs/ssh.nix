{
  osConfig,
  lib,
  pkgs,
  ...
}: let
  machines = osConfig.clan.inventory.machines;
  sshConnect = "${pkgs.writeShellScript "ssh-connect.sh" ''
    for i in "$@"; do
      nc -z -w 2 $i $PORT && exec nc $i $PORT && exit
    done
    echo "Couldnt connect to host"
    exit 1

  ''}";
  names =
    lib.attrNames
    (
      lib.removeAttrs machines
      [osConfig.networking.hostName]
    );
  tlds = ["" ".${osConfig.clan.mycelium-static-hosts.topLevelDomain}"];
  every = lib.pipe names [
    (
      map (
        y:
          map (x: {
            tld = x;
            host = y;
            hostname = "${y}${x}";
          })
          tlds
      )
    )
    lib.flatten
  ];
in {
  programs.ssh = {
    enable = true;
    matchBlocks = lib.pipe osConfig.networking.hosts [
      (
        lib.mapAttrs (_:
          lib.filter (x: lib.elem x (map (x: x.hostname) every)))
      )
      (lib.filterAttrs (_: v: lib.length v > 0))
      (lib.mapAttrsToList (
        n: v:
          map (x: let
            host = lib.findFirst (y: y.hostname == x) null every;
          in {
            hostname = x;
            ip = n;
            host = host.host;
          })
          v
      ))
      lib.flatten
      (lib.groupBy (x: x.host))
      (lib.mapAttrs (n: v: let
        machine = machines.${n};

        splited = lib.strings.splitString "@" machine.deploy.targetHost;
      in {
        setEnv.TERM = "xterm-256color";
        user = lib.elemAt splited 0;
        proxyCommand = "PORT=22 ${sshConnect} ${
          lib.strings.concatStringsSep " "
          (map (x: "\"${x.hostname}\"") v)
        }";
      }))
    ];
  };
}
