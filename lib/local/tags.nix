{lib, ...}: rec {
  groups = rec {
    desktop = ["kami"];
    cloudProviders = ["shou"];
    server = cloudProviders ++ ["villainess"];
    # inherit (types) server;
  };
  getAll = machines:
    lib.pipe machines [
      (lib.mapAttrs (_: v: v.tags))
      lib.attrValues
      lib.flatten
      lib.unique
    ];

  toInventory = allTags: tags:
    lib.listToAttrs (
      map (x: {
        name = x;
        value = {};
      })
      (lib.lists.intersectLists allTags tags)
    );

  getSpecial = tag: tags: let
    sp = lib.filter (lib.hasPrefix "${tag}:") tags;
  in
    if lib.length sp == 1
    then
      lib.removePrefix "${tag}:"
      (lib.head sp)
    else null;
  # getTagOrNull
  getSystem = tags: let
    arch = getSpecial "arch" tags;
    sys =
      if lib.elem "nixos" tags
      then "linux"
      else if lib.elem "darwin" tags
      then "darwin"
      else null;
  in
    if arch != null && sys != null
    then "${arch}-${sys}"
    else null;
}
