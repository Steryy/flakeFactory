{
  inputs,
  config,
  flakeRoot,
  ...
}: {
  imports = [
    inputs.easy-hosts.flakeModule
  ];
  easy-hosts = {
    shared.modules = [
      ({
        options,
        lib,
        ...
      }: {
        config = lib.optionalAttrs (options ? "home-manager") {
          home-manager.extraSpecialArgs = {
            inherit flakeRoot inputs;
          };
        };
      })
    ];
    shared.specialArgs = {
      inherit inputs;
      inherit flakeRoot;
    };
  };
}
