{
  config,
  lib,
  flakeRoot,
  ...
}: let
  baseIp = host: "\"${
    builtins.readFile
    "${flakeRoot}/vars/per-machine/${host}/zerotier/zerotier-ip/value"
  }\"";
  inherit (lib.local.terranix.cloudGroups) shou;
  domain = "stanley-dev.net";
  zt = lib.pipe config.clan.inventory.instances [
    (lib.filterAttrs (n: v: v.module.name == "zerotier"))
    lib.attrValues
    (map (x: lib.attrNames x.roles.controller.machines))
    lib.flatten
    (map (x: {
      type =
        lib.head
        (lib.splitString "-" x);
      key = x;
    }))
    lib.head
  ];

  exposed =
    lib.pipe
    config.flake.nixosConfigurations
    [
      (lib.filterAttrs (n: v: v.config.networking ? "exposedServices" && v.config.networking.exposedServices != {}))
      (lib.mapAttrs (_: v: v.config.networking.exposedServices))
      (lib.mapAttrsToList (n: v: {
        host = n;
        services = lib.attrNames v;
      }))
      (
        map (x:
          map (y: {
            value = {
              hostname = x.host;
              ipv6 =
                baseIp x.host;
              ipv4 = "null";
              centername = "home";
            };
            name = y;
          })
          x.services)
      )
      lib.flatten
      lib.listToAttrs
    ];
in {
  flake.exposed = exposed;
  perSystem = {pkgs, ...}: {
    config.terranix = let
      package = pkgs.opentofu.withPlugins (p: [
        p.external
        p.local
        p.cloudflare
      ]);
    in {
      terranixConfigurations.terraform-cloudflaire = {
        terraformWrapper.package = package;
        # modules = [
        #   ({lib, ...}: {
        #     resource.cloudflare_dns_record =
        #       (lib.mapAttrs' (name: v: {
        #           name = "${name}-${v.hostname}";
        #           value = {
        #             name = "${name}.${v.centername}.${domain}";
        #             type = lib.tfRef ''${v.ipv6} == null ? "A" : "AAAA"'';
        #             content = lib.tfRef "${v.ipv6} == null ? ${v.ipv4} : ${v.ipv6}";
        #             ttl = 1;
        #             zone_id = lib.tfRef "data.cloudflare_zones.domain.result[0].id";
        #           };
        #         })
        #         exposed)
        #       // {
        #         main-zerotier = let
        #           v = "data.terraform_remote_state.${zt.type}.outputs.instance_ips.${zt.key}";
        #         in {
        #           name = "zt.${domain}";
        #           type = lib.tfRef ''${v}.ipv6 == null ? "A" : "AAAA"'';
        #           content = lib.tfRef "${v}.ipv6 == null ? ${v}.ipv4 : ${v}.ipv6";
        #           ttl = 1;
        #           zone_id = lib.tfRef "data.cloudflare_zones.domain.result[0].id";
        #         };
        #       };
        #   })
        #
        #   {
        #     terraform.required_providers.cloudflare = {
        #       source = "cloudflare/cloudflare";
        #     };
        #   }
        #
        #   {
        #     provider = {
        #       cloudflare = {
        #       };
        #     };
        #     data = {
        #       cloudflare_zones."domain" = {
        #         name = domain;
        #       };
        #     };
        #     remote_state.git.shou = {
        #       owner = "Steryy";
        #       repo = "flakeFactory";
        #       path = "shou.state.json";
        #     };
        #   }
        # ];
        extraArgs = {
          localLib = lib.local;
          inventory = shou config.clan.inventory;
        };
        terraformWrapper.prefixText = ''
          CLOUDFLARE_API_TOKEN="$(clan secrets get cloudflare-api)"
          export CLOUDFLARE_API_TOKEN
          CLOUDFLARE_EMAIL="$(clan secrets get cloudflare-email)"
          export CLOUDFLARE_EMAIL
        '';
      };
    };
  };
}
