{
  lib,
  config,
  osConfig,
  extraInputs,
  ...
}: let
  homedir = config.home.homeDirectory;
  allDirs =
    lib.pipe
    config.persistence
    [
      (lib.filterAttrs (_: v: v ? "directories"))
      (lib.attrsets.mapAttrsToList (
        _: v:
          v.directories
      ))
      lib.flatten
      (map (x: {name = x.directory; value = {};}))
      lib.listToAttrs
      (x: lib.mapAttrs (n: _: lib.filter (x: x != n && lib.hasPrefix  n x ) (lib.attrNames x)  ) x)
      (lib.filterAttrs (n: v: v != []))
      
      # (x:  map (y:  { "${y}" = builtins.any (z: z != y && lib.hasPrefix z y ) x ;} ) x  )
    ];
  #   lib.attrsets.mapAttrsToList (_: v:
  #   v.directories
  #
  # )  (lib.filterAttrs (_: v: v ? "directories") );
in {
  imports = [
    extraInputs.impermanence.homeManagerModules.impermanence
  ];
  options = {
    freef = lib.mkOption {
      type = lib.types.anything;
      default = allDirs;
    };
    persistence = let
      mkSt = type: {
        directory = lib.mkOption {
          type = lib.types.str;
          default =
            (osConfig
              .persistence
              ."${type}"
              .directory)
            + "${homedir}";
        };
        files = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        directories = lib.mkOption {
          type =
            lib.types.listOf
            (
              lib.types.coercedTo lib.types.str (d: {directory = d;})
              (lib.types.submodule {
                options = {
                  directory = lib.mkOption {
                    type = lib.types.str;
                    description = "The directory path to be linked.";
                  };
                  method = lib.mkOption {
                    type = lib.types.enum ["bindfs" "symlink"];
                    default = "bindfs";
                    description = ''
                      The linking method to be used for this specific
                      directory entry. See
                      <literal>defaultDirectoryMethod</literal> for more
                      information on the tradeoffs.
                    '';
                  };
                };
              })
            );
          default = [];
        };
      };
    in {
      state = mkSt "state";
      cache = mkSt "cache";
    };
  };
  config = {

  assertions = lib.attrsets.mapAttrsToList (n: v: {
    assertion =  false  ;
    message = "Directory ${n} is already linked, subdirectories: [${lib.strings.concatStringsSep " " v } ] are not needed";

  }) allDirs ;
    home.persistence =
      lib.mapAttrs' (_: v: {
        name = v.directory;
        value = {
          allowOther = true;
          inherit (v) directories files;
        };
      })
      config.persistence;
  };
}
