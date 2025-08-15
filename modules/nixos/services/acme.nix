{
  config,
  lib,
  exports,
  ...
}: let
  provider = config.clan.core.vars.generators.acme.files.provider.value;
  dnsResorvers = {cloudflare = "1.1.1.1:53";};
in {
  config = {
    users.groups.acme.members = [config.services.nginx.user];
    # # users.users."${config.services.nginx.user}".extra
    systemd.services."acme-fixperms".wants = ["bind.service"];
    systemd.services."acme-fixperms".after = ["bind.service"];
    #
    security.acme = {
      acceptTerms = true;
      defaults = {
        dnsProvider = provider;

        dnsResolver =
          if dnsResorvers ? "${provider}"
          then dnsResorvers."${provider}"
          else throw "${provider} not supported";
      };
      certs = lib.pipe exports.instances [
        (lib.filterAttrs (_: v: v.type == "ssh-share" && v.settings ? "srcDirectory" && v.settings.srcDirectory == "/var/lib/acme"))
        (lib.attrValues)
        (map (x: x.specialExports.subDirs))
        lib.flatten
        (map (u: {
          name = u;
          value = {
            domain = "${u}";
            extraDomainNames = ["*.${u}"];
            dnsPropagationCheck = true;
          };
        }))
        lib.listToAttrs
      ];
    };
    #
    clan.core = {
      vars.generators.acme = {
        files = {provider = {secret = false;};};
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
    security.acme.email = "contact@stanley-dev.net";
  };
}
