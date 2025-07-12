{
  pkgs,
  options,
  lib,
  config,
  ...
}: let
  forCol = file: attrs:
    lib.concatStringsSep "\n"
    (
      lib.flatten (
        lib.mapAttrsToList (
          n:
            map (x:
              ''
                substituteInPlace ${file} \
                --replace-fail '${x}' '#${n}'
              '')
        )
        attrs
      )
    );
in {
  config = lib.mkMerge [
    (lib.optionalAttrs (options ? "stylix") {
      nixpkgs.overlays = [
        (self: super: {
          nixos-icons = super.nixos-icons.overrideAttrs (oldAttrs: {
            src = pkgs.applyPatches {
              inherit (oldAttrs) src;
              prePatch = with config.lib.stylix.colors; ''
                ${forCol "logo/nix-snowflake-white.svg" {
                  "${base05}" = ["#ffffff"];
                }}
                ${
                  forCol "logo/nix-snowflake-colours.svg"
                  {
                    "${base0C}" = [
                      "#7eb1dd"
                      "#7ebae4"
                      "#699ad7"


                      "#6478fa"
                      "#719efa"
                    ];
                    "${base0D}" = [
                      "#415e9a"
                      "#4a6baf"
                      "#5277c3"
                      "#637ddf"
                    ];
                    "${base0E}" = [
                      "#7363df"
                    ];
                    "${base00}" = ["#000000"];
                    "${base05}" = ["#ffffff"];

                    # "#000000" = base00;
                    # "#ffffff" = base05;
                  }
                }
              '';
            };
          });
        })
      ];
    })
  ];
}
