{
  lib,
  hlib,
  flakeRoot,
  ...
}: let
  loader = hlib.loaders.path;
  modules = {
    homeModules = hlib.load {
      src = ../../modules/home;
      inherit loader;
    };
    groupModules = hlib.load {
      src = ../../modules/clan/groups;
      inherit loader;
    };
    nixosModules = hlib.load {
      src = ../../modules/nixos;

      inherit loader;
    };
    tagsModules = hlib.load {
      src = ../../modules/clan/tags;
      inherit loader;
    };
  };
  modified =
    lib.mapAttrs (
      _: v:
        lib.pipe v [
          (lib.attrsets.mapAttrsRecursive
            (
              p: v:
                if v ? "default" && lib.isPath v.default
                then v.default
                else v
              # }
            ))
          (lib.mapAttrs (_: v: {
            default = v.default or {};
            required = v.required or {};
            all = lib.removeAttrs v ["default" "required"];
          }))
        ]
    )
    modules;
in {
  inherit modified;
  import = {
    type ? "tags",
    tags ? [],
    importer ? {},
    forced ? [],
    includeDef ? false,
  }: let
    m = modified."${type}Modules" or {};
    module =
      lib.filterAttrs (
        n: _:
        # true
          lib.elem n tags
      )
      m;
    helper = t:
      lib.mapAttrs (_: v: let
      in (lib.mapAttrsRecursive (_: _: {
          enable = true;
          type = t;
        })
        v."${t}" or {}))
      module;
    default = helper "default";
    required = helper "required";
  in
    if module != {}
    then
      lib.pipe importer
      (
        lib.optionals includeDef [
          (lib.recursiveUpdate default)
          (x: lib.recursiveUpdate x required)
        ]
        ++ [
          (attr:
            lib.updateManyAttrsByPath (
              map (x:
                x
                // {
                  update = val:
                    if lib.hasAttrByPath x.path attr
                    then val
                    else false;
                })
              forced
            )
            attr)
          (lib.updateManyAttrsByPath forced)
          (lib.mapAttrsRecursiveCond (x: !(x ? "enable"))
            (path: value: {inherit path;} // value))
          (lib.collect (x: x ? "path"))
          (lib.filter (
            x:
              if includeDef
              then x.enable == true
              else !(lib.head (lib.tail x.path)) == "required"
          ))
          (map (
            x: let
              p = x.path;

              t = x.type or null;
            in {
              path =
                [(lib.head p)]
                ++ (
                  if t == "default" || t == "required"
                  then [t]
                  else ["all"]
                )
                ++ (lib.tail p);
              enable = x.enable;
            }
          ))
          (map (x: let
            v =
              lib.getAttrFromPath
              x.path
              module;
          in {
            path =
              if lib.isAttrs v
              then v.default
              else v;
            type =
              if x.enable
              then "imports"
              else "disableModules";
          }))
          (lib.groupBy (x: x.type))
          (lib.mapAttrs (_: map (x: x.path)))
        ]
      )
    else {};
}
