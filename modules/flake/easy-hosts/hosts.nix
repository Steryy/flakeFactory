{
  lib,
  inputs,
  config,
  flakeRoot,
  ...
}: let
  l = lib // builtins;
  dir = flakeRoot + "/hosts";
  cfg = config.easy-hosts;
in {
  options.easy-hosts.functionsList = lib.mkOption {
    type = lib.types.listOf lib.types.anything;
    default = [];
  };
  config.easy-hosts .hosts = l.pipe dir [
    l.readDir
    (l.mapAttrs (n: _: dir + "/${n}"))
    (lib.mapAttrs (_: builtins.readDir))
    (lib.mapAttrs (n: l.filterAttrs (_: v: v == "directory")))
    (lib.mapAttrs (n:
      lib.mapAttrs' (n2: value: let
        path = "${dir}/${n}/${n2}";
      in {
        name = builtins.concatStringsSep "-" [n n2];
        value = {
          specialArgs = {
            inherit flakeRoot;
          };
          _path = path;
          modules = [];
          _hostName = n2;
          class = n;
        };
      })))

    lib.attrValues
    (map (lib.attrsets.attrsToList))
    lib.flatten

    lib.listToAttrs
    (
      lib.mapAttrs (
        _: v: let
          imp = import "${v._path}/default.nix";
        in
          lib.recursiveUpdate
          v
          imp
      )
    )
    (lib.mapAttrs (
      _: v:
        lib.recursiveUpdate v (
          lib.pipe v cfg.functionsList
        )
    ))
    (lib.mapAttrs (_: v: lib.removeAttrs v ["_path" "_hostName"]))
  ];
}
