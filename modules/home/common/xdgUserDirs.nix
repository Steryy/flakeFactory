{
  config,
  lib,
  options,
  ...
}: let
  toCache = n: lib.any (x: lib.strings.hasInfix x n) ["cache" "CACHE" "GPGHOME"];
  homeD = config.home.homeDirectory;
  userS = lib.filterAttrs (_: lib.isString) {
    inherit
      (config.xdg.userDirs)
      music
      videos
      pictures
      desktop
      documents
      publicShare
      templates
      ;
  };
in {
  config = lib.mkMerge [
    (lib.optionalAttrs (options ? "persistence") {
      persistence.cache.directories =
        lib.pipe
        config.xdg.userDirs.extraConfig
        [
          (lib.filterAttrs (n: _: (toCache n)))
          lib.attrValues
          (map (lib.removePrefix "${homeD}/"))
        ];
      persistence.state.directories =
        lib.pipe
        (
          config.xdg.userDirs.extraConfig // userS
        )
        [
          (lib.filterAttrs (n: _: !(toCache n)))
          lib.attrValues
          (map (lib.removePrefix "${homeD}/"))
        ];
    })
    {
      xdg = {
        enable = true;

        cacheHome = "${config.home.homeDirectory}/.cache";
        configHome = "${config.home.homeDirectory}/.config";
        dataHome = "${config.home.homeDirectory}/.local/share";
        stateHome = "${config.home.homeDirectory}/.local/state";

        userDirs = {
          enable = true;
          createDirectories = true;
          publicShare = lib.mkDefault null;
          templates = lib.mkDefault null;
          extraConfig = {
            GPGHOME = config.programs.gpg.homedir;
          };
        };
      };
    }
  ];
}
