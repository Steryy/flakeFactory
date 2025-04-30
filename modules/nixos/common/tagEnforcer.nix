{ config, lib, ... }:
let
  tag = lib.lists.remove [ "all" "nixos" ] config.clan.inventory.tags;
  serverProviders = [ "villainess" "shou" "seirei" ];
  isKami = lib.elem "kami" tag;
  factions = (lib.filter (x: lib.hasPrefix "faction-" x) tag);
  faction = lib.head factions;
  gatherFactions = lib.pipe config.clan.inventory.machines [
    (lib.filterAttrs (_: v: lib.elem faction v.tags))
    (lib.filterAttrs (_: v: lib.elem "shikikan" v.tags))
    lib.attrValues
    lib.length
  ];
in {
  assertions = [{

    assertion = isKami == (lib.length tag == 1);
    message = "Kami tags are only allowed on gui hosts";
  }] ++ map (x: x // { assertion = x.assertion == !isKami; }) [

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
        lib.length (lib.filter (x: lib.elem x tag) [ "senkan" "shikikan" ])
        != 2;
      message = "Kubernetes controller cant be Kubernetes node";
    }
  ];
}
