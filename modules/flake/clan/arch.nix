{
  config,
  lib,
  ...
}: let
  arch =
    lib.mapAttrs (
      _: v: let
        getArchs = lib.filter (lib.hasPrefix "arch:") v;
        arch = lib.head getArchs;
        leng = lib.length getArchs;
      in {
        tags =
          if leng > 0
          then []
          else ["arch:x86_64"];
        arch =
          if lib.length getArchs > 1
          then lib.removePrefix "arch:" arch
          else "x86_64";
        number = lib.length getArchs;
      }
    )
    config.defaultTags;
in {
  flake.clan.inventory.machines =
    lib.mapAttrs (_: v: {
      tags = v.tags;
    })
    arch;
  flake.clan.machines =
    lib.mapAttrs (n: v: let
      machineClass = config.flake.clan.inventory.machines."${n}".machineClass;
      os =
        {
          nixos = "linux";
          darwin = "darwin";
        }."${machineClass}";
    in {
      imports = [
        {
          nixpkgs.hostPlatform = "${v.arch}-${os}";
        }
      ];
    })
    arch;
}
