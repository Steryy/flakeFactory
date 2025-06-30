{
  config,
  lib,
  ...
}: let
  tag =
    lib.filter (x: !lib.elem x ["all" "nixos"]) config.clan.inventory.tags;
  serverProviders = ["villainess" "shou" "seirei"];
  isKami = lib.elem "kami" tag;
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
    );
}
