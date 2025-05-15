{ config, lib, ... }:
let
  tag =
    lib.filter (x: !lib.elem x [ "all" "nixos" ]) config.clan.inventory.tags;
  serverProviders = [ "villainess" "shou" "seirei" ];
  isKami = lib.elem "kami" tag;
  factions = (lib.filter (x: lib.hasPrefix "faction-" x) tag);
  gatherFactions = lib.pipe config.clan.inventory.machines [
    (lib.filterAttrs (_: v:
      let
        len = lib.length factions;
        faction = lib.head factions;
      in if len == 1 then lib.elem faction v.tags else false))
    (lib.filterAttrs (_: v: lib.elem "shikikan" v.tags))
    lib.attrValues
    lib.length
  ];
in {
  assertions = (lib.optionals (isKami) [{
    assertion = !(lib.any (x: lib.elem x tag)
      (serverProviders ++ [ "senkan" "shikikan" ]));
    message = "Kami tags are only allowed on gui hosts";
  }]) ++ (lib.optionals (!isKami) [
    {

      assertion = lib.length (lib.filter (x: lib.elem x tag) serverProviders)
        == 1;
      message = "Only one server provider is allowed per host";
    }
    {
      assertion = (lib.any (x: lib.elem x tag) [ "senkan" "shikikan" ])
        == (lib.length factions == 1);
      message = "Only one faction is allowed for Kubernetes";
    }
    {
      assertion = (lib.any (x: lib.elem x tag) [ "senkan" "shikikan" ])
        == (gatherFactions == 1);
      message = "Only one controller is allowed in faction";
    }
    {
      assertion =
        lib.length (lib.filter (x: lib.elem x tag) [ "senkan" "shikikan" ]) < 2;
      message = "Kubernetes controller cant be Kubernetes node";
    }
  ]);
}
