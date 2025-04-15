{ lib, inputs, ... }:
let
  haumea = inputs.haumea.lib;
  funAny = lib.types.functionTo lib.types.anything;
  loaderType = lib.types.functionTo funAny;
in {
  options.haumea = lib.mkOption {
    apply = lib.mapAttrs (_: v: v._output);
    type = lib.types.attrsOf (lib.types.submodule ({ config, ... }: {
      config._output =
        lib.pipe { inherit (config) transformer loader src inputs; }
        ([ haumea.load ] ++ (if lib.lists.isList config._pipe then
          config._pipe
        else
          [ (config._pipe) ]));
      options = {
        _output = lib.mkOption { type = lib.types.anything; };

        _pipe = lib.mkOption {
          type = lib.types.either (lib.types.listOf funAny) funAny;
          default = [ ];
        };
        src = lib.mkOption { type = lib.types.path; };
        inputs = lib.mkOption {
          type = lib.types.anything;
          default = {
            # inherit inputs;
          };
        };
        transformer = lib.mkOption {
          type = lib.types.anything;
          default = [ ];
        };

        loader = lib.mkOption {
          type = lib.types.anything;
          # type = lib.types.either loaderType (lib.types.listOf
          #   (lib.types.submodule {
          #     options = {
          #       matches =
          #         lib.mkOption { type = lib.types.functionTo lib.types.bool; };
          #       loader = loaderType;
          #     };
          #   }));
          default = haumea.loaders.path;
        };
      };
    }));
  };
}
