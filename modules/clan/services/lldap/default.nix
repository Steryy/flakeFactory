{lib, ...}: let
  genSecr = pkgs: files: {
    generators.lldap-passwords = {
      share = true;
      inherit files;
      runtimeInputs = [
        pkgs.openssl
      ];
      script =
        lib.concatMapStringsSep "\n"
        (x:
          #bash
          ''openssl rand -base64 32 | tr -d '\n' | tr -d ' ' >  "$out/${x}" '') (lib.attrNames files);
    };
  };
in {
  _class = "clan.service";
  manifest.name = "@local/lldap";
  imports = [
    ./server
    ./client.nix
  ];
  roles.client = {
    description = "Client for lldap server. It also allows for creating shared credentials with server.";

    perInstance = {
      settings,
      roles,
      machine,
      ...
    }: let
      names = lib.attrNames roles.server.machines;
    in {
      nixosModule = {pkgs, ...}: {
        config.clan.core.vars = lib.mkIf (! lib.elem machine.name names) (genSecr pkgs (
          lib.mapAttrs (_: _: {}) settings.ensureUsers
        ));
      };
    };
  };
  roles.server = {
    perInstance = {roles, ...}: let
      ensure = lib.pipe roles.client.machines [
        lib.attrValues
        (map (x: (x.settings).ensureUsers))
        (map (
          lib.mapAttrsToList (n: v: {
            name = n;
            value = {};
          })
        ))
        lib.flatten
        lib.listToAttrs
      ];
    in {
      nixosModule = {pkgs, ...}: {
        clan.core.vars = genSecr pkgs (
          lib.mapAttrs (_: _: {}) ensure
        );
      };
    };
  };
}
