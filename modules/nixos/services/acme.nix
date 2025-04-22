{ config, lib, inputs, ... }:
let
  provider = config.clan.core.vars.generators.acme.files.provider.value;
  dnsResorvers = { cloudflare = "1.1.1.1:53"; };
in {

  imports = [ inputs.clan-core.clanModules.nginx ];
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ name, ... }:
      let
        dom = lib.lists.findFirst (x: lib.strings.hasSuffix x name) null
          config.networking.domains;
      in {
        config = lib.mkIf (dom != null) {
          acmeRoot = null;
          useACMEHost = dom;
        };
      }));
  };
  config = {
    users.groups.acme.members = [ config.services.nginx.user ];
    # users.users."${config.services.nginx.user}".extra
    systemd.services."acme-fixperms".wants = [ "bind.service" ];
    systemd.services."acme-fixperms".after = [ "bind.service" ];

    clan.core = {
      vars.generators.acme = {

        files = { provider = { secret = false; }; };
        prompts = {

          "prov" = {
            type = "line";
            description = "Set provider (${
                lib.strings.concatStringsSep " " (lib.attrNames dnsResorvers)
              })";
          };
          "acme.env" = {
            type = "multiline";
            description = "Put provider env vars";
            persist = true;
          };
        };
        script = ''
          cp $prompts/prov $out/provider
        '';
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults = {
        dnsProvider = provider;

        dnsResolver = if dnsResorvers ? "${provider}" then
          dnsResorvers."${provider}"
        else
          throw "${provider} not supported";

        environmentFile =
          config.clan.core.vars.generators.acme.files."acme.env".path;
      };
      certs = lib.pipe (config.networking.domains) [
        (map (u: {
          name = u;
          value = {
            domain = "${u}";
            extraDomainNames = [ "*.${u}" ];
            dnsPropagationCheck = true;
          };
        }))
        lib.listToAttrs
      ];
    };
  };
}
