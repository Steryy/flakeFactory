{pkgs, ...}: {

  services.home-assistant = {
    lovelaceConfig = {
      strategy = {
        type = "custom:mushroom-strategy";
      };
      views = [];
    };
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      card-mod
      mini-graph-card
      (pkgs.callPackage ./packages/material.nix {})
      (pkgs.callPackage ./packages/moshroom-strategy.nix {})
      mushroom
    ];

    config = {
      frontend = {
        themes = "!include_dir_merge_named themes";
        extra_module_url = [
          "/local/nixos-lovelace-modules/material-you-utilities.min.js"
        ];
      };
      panel_custom = [
        {
          name = "material-you-panel";
          url_path = "material-you-configuration";
          sidebar_title = "Material You Utilities";
          sidebar_icon = "mdi:material-design";
          module_url = "/local/nixos-lovelace-modules/material-you-utilities.min.js";
        }
      ];
    };
  };
}
