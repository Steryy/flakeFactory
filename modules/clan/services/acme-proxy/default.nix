{lib, ...}: {
  _class = "clan.service";
  manifest.name = "@local/acme-proxy";
  imports = [
    ./proxy.nix
    ./client.nix
  ];
  perMachine = {
    instances,
    machine,
    ...
  }: let
    domains = lib.pipe instances [
      (lib.mapAttrsToList (n: v: {
        name = n;
        value =
          v.roles.client.machines;
      }))
      (lib.filter (x: x.value ? "${machine.name}"))
      # (map (x: x."${machine.name}".settings))
      (map (
        x:
          (import ./_helper.nix {inherit lib;}).getDomains {
            inherit machine;
            instanceName = x.name;
            settings = x.value."${machine.name}".settings;
          }
      ))
      lib.flatten
    ];
  in {
    exports = {
      domains = domains;
    };
  };
}
