{ lib, inputs, config, flakeRoot, ... }: {
  imports = [ inputs.easy-hosts.flakeModule ];
  easy-hosts = {

    functionsList =
      [ (x: { modules = [{ _module.args.class = lib.mkForce x.class; }]; }) ];
    shared.modules = [
      { nix.settings.experimental-features = [ "nix-command" "flakes" ]; }
      ({ options, lib, ... }: {
        config = lib.optionalAttrs (options ? "home-manager") {
          home-manager.sharedModules = [{
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
          }];
          home-manager.extraSpecialArgs = { inherit flakeRoot inputs; };
        };
      })
    ];
    shared.specialArgs = {
      inherit inputs;
      inherit flakeRoot;
      homeModules = config.haumea.homeModules;
    };
  };
}
