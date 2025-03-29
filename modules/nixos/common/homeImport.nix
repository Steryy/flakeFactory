{
  inputs,
  config,
  lib,
  ...
}: let
  hn = config.networking.hostName;
  dir = inputs.self.outPath + "/homes";

  users = lib.pipe dir [
    builtins.readDir
    (lib.mapAttrs (n: _: dir + "/${n}"))

    (lib.mapAttrs (_: builtins.readDir))
    (lib.mapAttrs (_:
      lib.filterAttrs (
        n: _: let
          hos = lib.removeSuffix ".nix" n;
        in
          hos == hn
      )))
    (lib.filterAttrs (_: v: v != {}))
    (
      lib.mapAttrs (n: v: let
        type = v."${hn}";
      in {
        imports = [
          {
            home = lib.mkDefault {
              username = n;
              homeDirectory = "/home/${n}";
              stateVersion = "25.05";
            };
          }
          (dir
            + "/${n}/${hn}"
            + (
              if type == "directory"
              then "/default.nix"
              else ""
            ))
        ];
      })
    )
  ];
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  config.
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    inherit users;
  };
}
