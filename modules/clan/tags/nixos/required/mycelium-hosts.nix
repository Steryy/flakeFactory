{ lib, config, ... }:
{
  options.clan.mycelium-static-hosts = {
    excludeHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Hosts that should be excluded";
    };
    topLevelDomain = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Top level domain to reach hosts";
    };
  };

  config.networking.hosts =
    let
      dir = config.clan.core.settings.directory;
      machineDir = "${dir}/vars/per-machine";
      zerotierIpMachinePath = machine: "${machineDir}/${machine}/mycelium/ip/value";
      machinesFileSet = builtins.readDir machineDir;
      machines = lib.mapAttrsToList (name: _: name) machinesFileSet;
      networkIpsUnchecked = builtins.map (
        machine:
        let
          fullPath = zerotierIpMachinePath machine;
        in
        if builtins.pathExists fullPath then machine else null
      ) machines;
      networkIps = lib.filter (machine: machine != null) networkIpsUnchecked;
      machinesWithIp = lib.filterAttrs (name: _: (lib.elem name networkIps)) machinesFileSet;
      filteredMachines = lib.filterAttrs (
        name: _: !(lib.elem name config.clan.mycelium-static-hosts.excludeHosts)
      ) machinesWithIp;
    in
    lib.filterAttrs (_: value: value != null) (
      lib.mapAttrs' (
        machine: _:
        let
          path = zerotierIpMachinePath machine;
        in
        if builtins.pathExists path then
          lib.nameValuePair (lib.strings.replaceStrings ["\n" ] [""] (builtins.readFile path)) (
            if (config.clan.mycelium-static-hosts.topLevelDomain == "") then
              [ machine ]
            else
              [ "${machine}.${config.clan.mycelium-static-hosts.topLevelDomain}" ]
          )
        else
          { }
      ) filteredMachines
    );
}
