{
  extraInputs,
  config,
  lib,
  flakeRoot,
  options,
  inputs,
  ...
}: let
  hn = config.networking.hostName;
  dir = flakeRoot + "/homes";

  users = lib.pipe dir [
    builtins.readDir
    (lib.filterAttrs (_: v: v == "directory"))
    (lib.mapAttrs (n: _: dir + "/${n}"))
    (lib.mapAttrs (_: builtins.readDir))
    (lib.mapAttrs (_: lib.filterAttrs (_: v: v == "directory")))
    (lib.mapAttrs (user:
      lib.filterAttrs (n: _: let
        hos = lib.removeSuffix ".nix" n;
      in
        hos == hn && lib.pathExists "${dir}/${user}/${hn}/default.nix")))
    (lib.filterAttrs (_: v: v != {}))
    (lib.mapAttrs (n: _: let
      direc = "${dir}/${n}/${hn}";
    in {
      imports =
        [
          "${direc}/default.nix"
        ]
        ++ lib.optional (lib.pathExists "${direc}/importer.nix") (
          lib.local.importer.import {
            type = "home";
            importer = (import "${direc}/importer.nix").importer;
            includeDef = true;
            forced = [
              {
                path = ["inputs" "impermanance" "enable"];
                update = _: (options ? "persistence");
              }
              {
                path = ["inputs" "stylix" "enable"];
                update = old:
                  if old
                  then !(options ? "stylix")
                  else old;
              }
            ];
            tags = config.clan.inventory.tags ++ ["inputs" "homeProfiles"];
          }
        );
    }))
  ];
in {
  imports = [extraInputs.home-manager.nixosModules.home-manager];
  config = {
    home-manager = {
      useGlobalPkgs = true;
      backupFileExtension = "backupe";
      sharedModules = [{nix.settings.experimental-features = ["nix-command" "flakes"];}];
      extraSpecialArgs = {inherit flakeRoot extraInputs inputs;};
      inherit users;
      # inherit users;
    };
  };
}
