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

  options.easy-hosts.hostsBare = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        _secrets = lib.mkEnableOption "Enable secrets for host" // {default = true;};
        _path = lib.mkOption {
          type = lib.types.path;
        };

        _hostName = lib.mkOption {
          type = lib.types.str;
        };

        class = lib.mkOption {
          type = lib.types.str;
        };
      };
    });
    default = {};
  };
  config.easy-hosts.hostsBare = lib.pipe dir [
    l.readDir
    (l.mapAttrs (n: _: dir + "/${n}"))
    (lib.mapAttrs (_: builtins.readDir))
    (lib.mapAttrs (n: l.filterAttrs (_: v: v == "directory")))
    (lib.mapAttrs (class:
      lib.mapAttrs' (n: _: let
        _path = dir + "/${class}/${n}";

        name = builtins.concatStringsSep "-" [class n];
      in {
        inherit name;
        value = {
          _hostName = name;
          inherit _path class;
        };
      })))

    lib.attrValues
    (map (lib.attrsets.attrsToList))
    lib.flatten

    lib.listToAttrs
  ];
  config.easy-hosts .hosts = l.pipe config.easy-hosts.hostsBare [
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
        lib.foldl
        (
          acc: next: let
            n = next v;
          in
            lib.recursiveUpdate acc
            (
              n
              // {
                modules =
                  (acc.modules or [])
                  ++ (n.modules or []);
              }
            )
        )
        {}
        (cfg.functionsList ++ [(_: v)])
      # lib.recursiveUpdate
      # v (
      #   {}
      #   # lib.pipe v cfg.functionsList
      # )
    ))
    (lib.mapAttrs (_: v: lib.removeAttrs v ["_path" "_hostName" "_secrets"]))
  ];
}
