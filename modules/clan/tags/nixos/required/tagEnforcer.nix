{
  config,
  lib,
  ...
}: let
  tag =
    lib.filter (x: !lib.elem x ["all" "nixos"]) config.clan.inventory.tags;
  serverProviders = ["villainess" "shou" "seirei"];
  isKami = lib.elem "kami" tag;

  rolesCube = lib.filter (x: lib.any (y: lib.hasPrefix "${y}:" x) ["senkan" "shikikan"]) tag;
  split = lib.splitString ":";
  faction = lib.elemAt (split (lib.head rolesCube)) 1;

  getRoles = lib.pipe config.clan.inventory.machines [
    (lib.mapAttrs (_: v: lib.filter (x: lib.hasSuffix ":${faction}" x) v.tags))
    (lib.filterAttrs (_: v: lib.length v == 0))
    (lib.mapAttrs (_: v: lib.head (split (lib.head v))))
    lib.attrValues
    (lib.groupBy (x: x))
    (lib.mapAttrs (_: lib.length))
  ];


  providers = lib.filter (x: lib.elem x tag) serverProviders;
in {
  assertions =
    (lib.optional isKami {
      assertion =
        !(lib.any (x: lib.elem x tag)
          serverProviders);
      message = "Kami tags are only allowed on gui hosts";
    })
    ++ (
      lib.optional (!isKami)
      {
        assertion =
          lib.length providers
          == 1;
        message = "Only one server provider is allowed per host";
      }
    )
    ++ (lib.optionals (lib.length rolesCube > 0) [
      {
        assertion = !isKami;
        message = "Kami tags are only allowed on gui hosts";
      }
      {
        assertion = lib.length rolesCube == 1;
        message = "Only one role is allowed for host";
      }
      {
        assertion = getRoles ? "shikikan"  && getRoles ? "senkan";
        message = "Faction ${faction} needs to have at least one `shikikan` and one `senkan`";
      }
      {
        assertion =  getRoles ? "shikikan" && getRoles.senkan == 1;
        message = "Only one controller is allowed in faction ${faction}";
      }
    ]);
}
