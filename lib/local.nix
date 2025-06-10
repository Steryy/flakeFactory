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
in {
  fileFromGroup = {group, file}: 
    map (x: lib.readFile   x."${file}" )   (lib.collect (x: x ? "${file}") groups."${group}");
}
