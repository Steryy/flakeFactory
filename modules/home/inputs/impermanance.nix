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
          type = lib.types.listOf lib.types.str;
          default = [];
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
