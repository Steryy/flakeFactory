{
  lib,
  config,
  osConfig,
  inputs,
  ...
}: let
  homedir = config.home.homeDirectory;
in {
  imports = [
    inputs.impermanence.homeManagerModules.impermanence
  ];
  options = {
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
        directories = lib.mkOption {
          type = lib.types.listOf
            (lib.types.coercedTo lib.types.str (d: { directory = d; })
              (lib.types.submodule {
                options = {
                  directory = lib.mkOption {
                    type = lib.types.str;
                    description = "The directory path to be linked.";
                  };
                  method = lib.mkOption {
                    type = lib.types.enum [ "bindfs" "symlink" ];
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
          default = [ ];
        };
      };
    in {
      state = mkSt "state";
      cache = mkSt "cache";
    };
  };
  config = {
    home.persistence =
      lib.mapAttrs' (_: v: {
        name = v.directory;
        value = {
          inherit (v) directories;
        };
      })
      config.persistence;
  };
}
