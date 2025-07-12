{
  lib,
  flakeRoot,
  ...
}: let
  conc = lib.strings.concatStringsSep "/";
  pa = p: let
    recu = path:
      lib.mapAttrs (
        n: v:
          if v == "regular"
          then conc (path ++ [n])
          else recu (path ++ [n])
      ) (builtins.readDir (conc path));
  in
    recu [p];
  groups =
    pa "${flakeRoot}/sops/groups";

  getSpecialTag = tag: tags: let
    sp = lib.filter (lib.hasPrefix "${tag}:") tags;
  in
    if lib.length sp == 1
    then
      lib.removePrefix "${tag}:"
      (lib.head sp)
    else null;
in {
  fileFromGroup = {group, file}: 
    map (x: lib.readFile   x."${file}" )   (lib.collect (x: x ? "${file}") groups."${group}");
  usersFromGroup = group:
    map (x: x.users) (lib.collect (x: x ? "users") groups."${group}");
  inherit getSpecialTag;
  terranix = inventory: type: rec {
    inherit inventory;
    machines = lib.pipe inventory.machines [
      (lib.filterAttrs (_: v: lib.elem "shou" v.tags))
    ];

    regions = lib.pipe machines [
      lib.attrValues
      (map (x: getSpecialTag "region" x.tags))
      (lib.unique)
    ];
    forCartesianProduct = args: f:
      lib.listToAttrs (lib.mapCartesianProduct (x: f x)  args);

    forRegions = f: lib.listToAttrs (map (x: f x) regions);
    archs = lib.pipe machines [
      lib.attrValues
      (map
        (x: getSpecialTag "arch" x.tags))
      lib.unique
    ];
  };
}
