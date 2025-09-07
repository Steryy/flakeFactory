{lib, ...}: {
  getDomains = {
    instanceName,
    settings,
    machine,
  }:
    settings.domains
    ++ (map (
        x:
          lib.replaceStrings ["\${host}" "\${domain}"] [machine.name x]
          settings.domainFunction
      )
      settings.extraDomains);
}
