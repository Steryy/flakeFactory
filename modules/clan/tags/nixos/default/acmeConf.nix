{
  lib,
  config,
  ...
}: let
  findlocalTld = name:
    lib.findFirst (x: lib.hasSuffix ".${x}" name) null;

  outDir = "/var/lib/accountCerts";
in {
  options.security.acme = {
    localtlds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    certs = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule ({name, ...}: {
          config = let
            tld = findlocalTld name config.security.acme.localtlds;
          in {
            email = lib.mkIf  ( tld != null) "acme@noemail.local";
            server = lib.mkIf (tld != null) "https://ca.${tld}:1443/acme/acme/directory";
          };
        })
      );
    };
  };
}
